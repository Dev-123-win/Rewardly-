
const canvas = document.getElementById('gameCanvas');
const engine = new BABYLON.Engine(canvas, true);
const gameOverScreen = document.getElementById('gameOverScreen');
const restartButton = document.getElementById('restartButton');
const continueButton = document.getElementById('continueButton');

// --- Game State & Configuration ---
let isGameRunning = false;
let isPlayerInvincible = false;
let gameSpeed = 0.4;
const initialGameSpeed = 0.4;
const maxGameSpeed = 1.0;
const speedIncrement = 0.0001;
const coinManager = new CoinManager();

// --- Communication with Flutter ---
function sendToFlutter(message) {
    if (window.Print && window.Print.postMessage) {
        window.Print.postMessage(message);
    } else {
        console.log("Flutter Binding Not Available. Message: " + message);
    }
}

function revivePlayer() {
    isGameRunning = true;
    isPlayerInvincible = true;
    gameOverScreen.style.display = 'none';

    // Make the collider visible for debugging invincibility
    const playerCollider = scene.getMeshByName("playerCollider");
    if (playerCollider && playerCollider.material) {
        playerCollider.material.alpha = 0.2; 
    }

    setTimeout(() => {
        isPlayerInvincible = false;
        if (playerCollider && playerCollider.material) {
            playerCollider.material.alpha = 0; // Make it invisible again
        }
    }, 2500);
}

async function createScene() {
    const scene = new BABYLON.Scene(engine);
    scene.clearColor = new BABYLON.Color3.FromHexString("#2c3e50");

    // --- Camera & Lighting ---
    const camera = new BABYLON.FreeCamera("camera", new BABYLON.Vector3(0, 5, -12), scene);
    camera.setTarget(new BABYLON.Vector3(0, 2, 0));

    const light = new BABYLON.DirectionalLight("dirLight", new BABYLON.Vector3(-0.1, -1, 0.2), scene);
    light.position = new BABYLON.Vector3(0, 15, -15);
    light.intensity = 1.2;

    const shadowGenerator = new BABYLON.ShadowGenerator(1024, light);
    shadowGenerator.useBlurExponentialShadowMap = true;

    // --- Materials ---
    const obstacleMaterial = new BABYLON.StandardMaterial("obstacleMat", scene);
    obstacleMaterial.diffuseColor = new BABYLON.Color3.FromHexString("#9b59b6");

    const coinMaterial = new BABYLON.StandardMaterial("coinMat", scene);
    coinMaterial.emissiveColor = new BABYLON.Color3.FromHexString("#f1c40f");
    
    const colliderMaterial = new BABYLON.StandardMaterial("colliderMat", scene);
    colliderMaterial.alpha = 0; // Make the collider invisible

    // --- Player ---
    const lanes = [-3, 0, 3];
    let currentLane = 1;

    // Create a simple box for collision detection
    const playerCollider = BABYLON.MeshBuilder.CreateBox("playerCollider", { height: 1.8, width: 0.8, depth: 0.8 }, scene);
    playerCollider.material = colliderMaterial;
    playerCollider.position = new BABYLON.Vector3(lanes[currentLane], 0.9, 0);

    // Load Animated Character
    let playerAnimations;
    let runAnim, jumpAnim, duckAnim;

    try {
        const result = await BABYLON.SceneLoader.ImportMeshAsync("", "assets/", "character.glb", scene);
        const playerMesh = result.meshes[0];
        playerMesh.name = "playerMesh";
        playerMesh.scaling.scaleInPlace(0.9);
        playerMesh.rotation = new BABYLON.Vector3(0, Math.PI, 0); // Rotate to face forward
        
        // Parent the mesh to the collider
        playerMesh.parent = playerCollider;
        playerMesh.position = new BABYLON.Vector3(0, -0.9, 0); // Adjust position relative to collider

        shadowGenerator.addShadowCaster(playerMesh);

        playerAnimations = result.animationGroups;
        runAnim = playerAnimations.find(ag => ag.name === 'run');
        jumpAnim = playerAnimations.find(ag => ag.name === 'jump');
        duckAnim = playerAnimations.find(ag => ag.name === 'duck');

        if(runAnim) runAnim.start(true, 1.0, runAnim.from, runAnim.to, false);
        
    } catch (e) {
        console.error("Failed to load character model:", e);
        // Create a fallback sphere if loading fails
        const fallbackPlayer = BABYLON.MeshBuilder.CreateSphere("player", {diameter: 1.5}, scene);
        fallbackPlayer.material = new BABYLON.StandardMaterial("fallbackMat", scene);
        fallbackPlayer.material.diffuseColor = new BABYLON.Color3.Red();
        fallbackPlayer.parent = playerCollider;
        fallbackPlayer.position = new BABYLON.Vector3(0, -0.75, 0);
    }
    

    // --- Ground ---
    const ground = BABYLON.MeshBuilder.CreateGround("ground", {width: 10, height: 250}, scene);
    const gridMaterial = new BABYLON.GridMaterial("gridMat", scene);
    gridMaterial.mainColor = new BABYLON.Color3.FromHexString("#34495e");
    gridMaterial.lineColor = new BABYLON.Color3.FromHexString("#7f8c8d");
    ground.material = gridMaterial;
    ground.position.z = 80;
    ground.receiveShadows = true;

    // --- Object Pooling ---
    let obstaclePool = [];
    let coinPool = [];
    const POOL_SIZE = 20;

    function initializePools() {
        for (let i = 0; i < POOL_SIZE; i++) {
            // Obstacles
            let obstacle = BABYLON.MeshBuilder.CreateBox(`obstacle${i}`, {size: 1.8}, scene);
            obstacle.material = obstacleMaterial;
            obstacle.setEnabled(false);
            shadowGenerator.addShadowCaster(obstacle);
            obstaclePool.push(obstacle);

            // Coins
            const coin = BABYLON.MeshBuilder.CreateCylinder(`coin${i}`, {diameter: 1, height: 0.2}, scene);
            coin.material = coinMaterial;
            coin.setEnabled(false);
            coinPool.push(coin);
        }
    }

    function getInactiveFromPool(pool) {
        for (let i = 0; i < pool.length; i++) {
            if (!pool[i].isEnabled()) return pool[i];
        }
        return null;
    }
    
    function spawnObjects() {
        let occupiedLanes = new Set();
        const startZ = 40;
    
        for (let i = 0; i < POOL_SIZE; i++) {
            const zPos = startZ + i * 15;
            const laneIndex = Math.floor(Math.random() * 3);
    
            if (occupiedLanes.has(laneIndex)) continue; 
    
            // Decide whether to spawn an obstacle or a coin
            const spawnObstacle = Math.random() > 0.4;
    
            if (spawnObstacle) {
                const obstacle = getInactiveFromPool(obstaclePool);
                if (obstacle) {
                    const obstacleType = Math.random();
                    if (obstacleType > 0.66) { // Full height obstacle
                        obstacle.scaling = new BABYLON.Vector3(1, 1, 1);
                        obstacle.position = new BABYLON.Vector3(lanes[laneIndex], 0.9, zPos);
                    } else if (obstacleType > 0.33) { // Low hurdle (for jumping)
                        obstacle.scaling = new BABYLON.Vector3(1, 0.3, 1);
                        obstacle.position = new BABYLON.Vector3(lanes[laneIndex], 0.27, zPos);
                    } else { // High barrier (for ducking)
                        obstacle.scaling = new BABYLON.Vector3(1, 0.5, 1);
                        obstacle.position = new BABYLON.Vector3(lanes[laneIndex], 1.5, zPos);
                    }
                    obstacle.setEnabled(true);
                    occupiedLanes.add(laneIndex);
                }
            } else {
                const coin = getInactiveFromPool(coinPool);
                if (coin) {
                    coin.position = new BABYLON.Vector3(lanes[laneIndex], 0.75, zPos);
                    coin.setEnabled(true);
                }
            }
        }
    }

    // --- Controls & Animations ---
    function moveLane(direction) {
        const newLane = currentLane + direction;
        if (newLane >= 0 && newLane < lanes.length && isGameRunning) {
            currentLane = newLane;
            BABYLON.Animation.CreateAndStartAnimation('laneAnim', playerCollider, 'position.x', 30, 10, playerCollider.position.x, lanes[currentLane], BABYLON.Animation.ANIMATIONLOOPMODE_CONSTANT);
        }
    }

    let isJumpingOrDucking = false;
    function jump() {
        if (isJumpingOrDucking || !isGameRunning) return;
        isJumpingOrDucking = true;

        if (runAnim) runAnim.stop();
        if (jumpAnim) jumpAnim.start(false, 1.0, jumpAnim.from, jumpAnim.to, false);
        
        const jumpAnimation = new BABYLON.Animation("jump", "position.y", 30, BABYLON.Animation.ANIMATIONTYPE_FLOAT, BABYLON.Animation.ANIMATIONLOOPMODE_CONSTANT);
        jumpAnimation.setKeys([
            { frame: 0, value: playerCollider.position.y },
            { frame: 15, value: playerCollider.position.y + 2.5 },
            { frame: 30, value: playerCollider.position.y }
        ]);
        playerCollider.animations = [jumpAnimation];
        scene.beginAnimation(playerCollider, 0, 30, false, 1.0, () => {
            isJumpingOrDucking = false;
            if (runAnim) runAnim.start(true, 1.0, runAnim.from, runAnim.to, false);
        });
    }

    function duck() {
        if (isJumpingOrDucking || !isGameRunning) return;
        isJumpingOrDucking = true;

        if (runAnim) runAnim.stop();
        if (duckAnim) duckAnim.start(false, 1.5, duckAnim.from, duckAnim.to, false);

        const duckAnimation = new BABYLON.Animation("duck", "scaling.y", 30, BABYLON.Animation.ANIMATIONTYPE_FLOAT, BABYLON.Animation.ANIMATIONLOOPMODE_CONSTANT);
        duckAnimation.setKeys([
            { frame: 0, value: 1 },
            { frame: 8, value: 0.5 },
            { frame: 22, value: 0.5 },
            { frame: 30, value: 1 }
        ]);
        playerCollider.animations = [duckAnimation];
        scene.beginAnimation(playerCollider, 0, 30, false, 1.0, () => {
            isJumpingOrDucking = false;
            if (runAnim) runAnim.start(true, 1.0, runAnim.from, runAnim.to, false);
        });
    }

    let touchStartX = 0, touchStartY = 0;
    const onTouchStart = (evt) => {
        touchStartX = evt.touches[0].clientX;
        touchStartY = evt.touches[0].clientY;
    };
    const onTouchEnd = (evt) => {
        if (!touchStartX || !touchStartY) return;

        const diffX = evt.changedTouches[0].clientX - touchStartX;
        const diffY = evt.changedTouches[0].clientY - touchStartY;

        if (Math.abs(diffX) > Math.abs(diffY)) {
            if (Math.abs(diffX) > 20) moveLane(diffX > 0 ? 1 : -1);
        } else {
            if (Math.abs(diffY) > 20) {
                if (diffY < 0) jump();
                else duck();
            }
        }
        touchStartX = 0;
        touchStartY = 0;
    };
    const onKeyDown = (evt) => {
        if (!isGameRunning) return;
        if (evt.key === 'ArrowLeft') moveLane(-1);
        if (evt.key === 'ArrowRight') moveLane(1);
        if (evt.key === 'ArrowUp') jump();
        if (evt.key === 'ArrowDown') duck();
    };

    // --- Game Over & Restart ---
    function endGame() {
        if (!isGameRunning) return;
        isGameRunning = false;
        gameOverScreen.style.display = 'flex';
        if(runAnim) runAnim.stop();
        if(jumpAnim) jumpAnim.stop();
        if(duckAnim) duckAnim.stop();
    }

    function restartGame() {
        playerCollider.position = new BABYLON.Vector3(lanes[1], 0.9, 0);
        playerCollider.scaling.y = 1;
        currentLane = 1;
        ground.position.z = 80;
        gameSpeed = initialGameSpeed;
        
        obstaclePool.forEach(o => o.setEnabled(false));
        coinPool.forEach(c => c.setEnabled(false));

        spawnObjects();
        coinManager.reset();
        gameOverScreen.style.display = 'none';
        
        isGameRunning = true;
        isPlayerInvincible = false;
        isJumpingOrDucking = false;
        
        if(runAnim) runAnim.start(true, 1.0, runAnim.from, runAnim.to, false);
    }

    restartButton.addEventListener('click', restartGame);
    continueButton.addEventListener('click', () => sendToFlutter("watchAdToContinue"));

    // --- Main Game Loop ---
    scene.onBeforeRenderObservable.add(() => {
        if (!isGameRunning) return;

        if (gameSpeed < maxGameSpeed) gameSpeed += speedIncrement;

        ground.position.z -= gameSpeed;
        if (ground.position.z < -125) {
            ground.position.z += 250; 
            spawnObjects();
        }

        for (const item of [...obstaclePool, ...coinPool]) {
            if (item.isEnabled()) {
                item.position.z -= gameSpeed;
                if (item.position.z < camera.position.z) {
                    item.setEnabled(false);
                } else if (item.intersectsMesh(playerCollider, false)) {
                    if (item.name.startsWith("obstacle")) {
                        if (!isPlayerInvincible) {
                            endGame();
                            break;
                        }
                    } else if (item.name.startsWith("coin")) {
                        coinManager.collectCoin(item.id);
                        item.setEnabled(false);
                    }
                }
                 // Coin specific animation
                if (item.name.startsWith("coin")) {
                    item.rotation.y += 0.1;
                }
            }
        }
    });
    
    // --- Start Game ---
    function setupControls() {
        window.addEventListener('keydown', onKeyDown);
        window.addEventListener('touchstart', onTouchStart, { passive: true });
        window.addEventListener('touchend', onTouchEnd, { passive: true });
    }

    initializePools();
    setupControls();
    restartGame();

    return scene;
}

createScene().then(scene => {
    engine.runRenderLoop(() => {
        if (scene) {
            scene.render();
        }
    });
});

window.addEventListener('resize', () => {
    engine.resize();
});
