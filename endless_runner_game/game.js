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

// --- Communication with Flutter ---
function sendToFlutter(message) {
    if (window.Print && window.Print.postMessage) {
        window.Print.postMessage(message);
    } else {
        console.log("Flutter Binding Not Available. Message: " + message);
    }
}

// Called from Flutter to revive the player
function revivePlayer() {
    isGameRunning = true;
    isPlayerInvincible = true;
    gameOverScreen.style.display = 'none';

    const player = scene.getMeshByName("player");
    player.material.alpha = 0.5; // Visual feedback for invincibility

    setTimeout(() => {
        isPlayerInvincible = false;
        player.material.alpha = 1.0; // Return to normal
    }, 2500); // Increased invincibility time slightly
}

function createScene() {
    const scene = new BABYLON.Scene(engine);
    scene.clearColor = new BABYLON.Color3.FromHexString("#2c3e50");

    // --- Camera & Lighting ---
    const camera = new BABYLON.FreeCamera("camera", new BABYLON.Vector3(0, 6, -12), scene);
    camera.setTarget(new BABYLON.Vector3(0, 2, 0));

    const light = new BABYLON.DirectionalLight("dirLight", new BABYLON.Vector3(-0.1, -1, 0.2), scene);
    light.position = new BABYLON.Vector3(0, 15, -15);
    light.intensity = 1.2;

    const shadowGenerator = new BABYLON.ShadowGenerator(1024, light);
    shadowGenerator.useBlurExponentialShadowMap = true;

    // --- Materials ---
    const playerMaterial = new BABYLON.StandardMaterial("playerMat", scene);
    playerMaterial.diffuseColor = new BABYLON.Color3.FromHexString("#e74c3c");

    const obstacleMaterial = new BABYLON.StandardMaterial("obstacleMat", scene);
    obstacleMaterial.diffuseColor = new BABYLON.Color3.FromHexString("#9b59b6");

    const coinMaterial = new BABYLON.StandardMaterial("coinMat", scene);
    coinMaterial.emissiveColor = new BABYLON.Color3.FromHexString("#f1c40f");

    // --- Player ---
    const player = BABYLON.MeshBuilder.CreateSphere("player", {diameter: 1.5}, scene);
    player.position.y = 0.75;
    player.material = playerMaterial;
    shadowGenerator.addShadowCaster(player);

    const lanes = [-3, 0, 3];
    let currentLane = 1;
    player.position.x = lanes[currentLane];

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
    const POOL_SIZE = 15;

    function initializePools() {
        for (let i = 0; i < POOL_SIZE; i++) {
            // Obstacles
            let obstacle = obstaclePool[i] || BABYLON.MeshBuilder.CreateBox(`obstacle${i}`, {size: 2}, scene);
            obstacle.material = obstacleMaterial;
            obstacle.setEnabled(false);
            shadowGenerator.addShadowCaster(obstacle);
            if (!obstaclePool[i]) obstaclePool.push(obstacle);

            // Coins
            const coin = coinPool[i] || BABYLON.MeshBuilder.CreateCylinder(`coin${i}`, {diameter: 1, height: 0.2}, scene);
            coin.material = coinMaterial;
            coin.setEnabled(false);
            if (!coinPool[i]) coinPool.push(coin);
        }
    }

    function getInactiveFromPool(pool) {
        for (let i = 0; i < pool.length; i++) {
            if (!pool[i].isEnabled()) return pool[i];
        }
        return null; // Pool exhausted
    }

    function spawnObjects() {
        let occupiedLanes = new Set();

        for (let i = 0; i < POOL_SIZE; i++) {
            const zPos = 30 + i * 18;
            const lane = Math.floor(Math.random() * 3);

            if (occupiedLanes.has(`${zPos}-${lane}`)) continue;

            if (Math.random() > 0.4) { // Spawn obstacle
                const obstacle = getInactiveFromPool(obstaclePool);
                if (obstacle) {
                    obstacle.position = new BABYLON.Vector3(lanes[lane], 1, zPos);
                    obstacle.setEnabled(true);
                    occupiedLanes.add(`${zPos}-${lane}`);
                }
            } else { // Spawn coin
                const coin = getInactiveFromPool(coinPool);
                if (coin) {
                    coin.position = new BABYLON.Vector3(lanes[lane], 0.75, zPos);
                    coin.setEnabled(true);
                    occupiedLanes.add(`${zPos}-${lane}`);
                }
            }
        }
    }

    // --- Controls ---
    function moveLane(direction) {
        const newLane = currentLane + direction;
        if (newLane >= 0 && newLane < lanes.length) {
            currentLane = newLane;
            BABYLON.Animation.CreateAndStartAnimation('laneAnim', player, 'position.x', 30, 10, player.position.x, lanes[currentLane], BABYLON.Animation.ANIMATIONLOOPMODE_CONSTANT);
        }
    }

    let touchStartX = 0;
    const onTouchStart = (evt) => touchStartX = evt.touches[0].clientX;
    const onTouchMove = (evt) => {
        if (!isGameRunning || !touchStartX) return;
        const diff = evt.touches[0].clientX - touchStartX;
        if (Math.abs(diff) > 40) {
            moveLane(diff > 0 ? 1 : -1);
            touchStartX = 0;
        }
    };
    const onKeyDown = (evt) => {
        if (!isGameRunning) return;
        if (evt.key === 'ArrowLeft') moveLane(-1);
        if (evt.key === 'ArrowRight') moveLane(1);
    };

    // --- Game Over & Restart ---
    function endGame() {
        if (!isGameRunning) return;
        isGameRunning = false;
        gameOverScreen.style.display = 'flex';
    }

    function restartGame() {
        isGameRunning = true;
        isPlayerInvincible = false;
        player.position.x = lanes[1];
        currentLane = 1;
        ground.position.z = 80;
        gameSpeed = initialGameSpeed;

        obstaclePool.forEach(o => o.setEnabled(false));
        coinPool.forEach(c => c.setEnabled(false));

        spawnObjects();
        coinManager.reset();
        gameOverScreen.style.display = 'none';
    }

    restartButton.addEventListener('click', restartGame);
    continueButton.addEventListener('click', () => sendToFlutter("watchAdToContinue"));

    // --- Main Game Loop ---
    scene.onBeforeRenderObservable.add(() => {
        if (!isGameRunning) return;

        // Increase speed over time
        if (gameSpeed < maxGameSpeed) {
            gameSpeed += speedIncrement;
        }

        ground.position.z -= gameSpeed;
        if (ground.position.z < -125) {
            ground.position.z = 125;
            spawnObjects(); // Respawn objects when ground resets
        }

        // Update obstacles
        for (const obstacle of obstaclePool) {
            if (obstacle.isEnabled()) {
                obstacle.position.z -= gameSpeed;
                if (obstacle.position.z < camera.position.z) obstacle.setEnabled(false);
                if (!isPlayerInvincible && player.intersectsMesh(obstacle, false)) {
                    obstacle.setEnabled(false); // FIX: Disable obstacle on collision
                    endGame();
                    break; // Exit loop after one collision
                }
            }
        }

        // Update coins
        for (const coin of coinPool) {
            if (coin.isEnabled()) {
                coin.rotation.y += 0.1;
                coin.position.z -= gameSpeed;
                if (coin.position.z < camera.position.z) coin.setEnabled(false);

                if (player.intersectsMesh(coin, false)) {
                    coinManager.collectCoin(coin.id);
                    coin.setEnabled(false); // Collect coin
                }
            }
        }
    });
    
    // --- Start Game --- //
    function setupControls() {
        window.addEventListener('keydown', onKeyDown);
        window.addEventListener('touchstart', onTouchStart, {passive: true});
        window.addEventListener('touchmove', onTouchMove, {passive: true});
    }

    initializePools();
    setupControls();
    restartGame(); // Start the game for the first time

    return scene;
}

const scene = createScene();

engine.runRenderLoop(() => {
    if (scene) {
        scene.render();
    }
});

window.addEventListener('resize', () => {
    engine.resize();
});
