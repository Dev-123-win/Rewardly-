const canvas = document.getElementById('gameCanvas');
const engine = new BABYLON.Engine(canvas, true);
const gameOverScreen = document.getElementById('gameOverScreen');
const restartButton = document.getElementById('restartButton');
const continueButton = document.getElementById('continueButton');

// --- Game State ---
let isGameRunning = true;
let isPlayerInvincible = false;

// --- Communication Bridge --- //
function sendToFlutter(message) {
    if (window.Print && window.Print.postMessage) {
        window.Print.postMessage(message);
    } else {
        console.log("Sent to Flutter: " + message);
    }
}

function revivePlayer() {
    isGameRunning = true;
    isPlayerInvincible = true;
    gameOverScreen.style.display = 'none';

    // Make player invincible for a short time after reviving
    setTimeout(() => {
        isPlayerInvincible = false;
    }, 2000);
}

// --- Game Setup --- //
function createScene() {
    const scene = new BABYLON.Scene(engine);
    scene.clearColor = new BABYLON.Color3.FromHexString("#2c3e50"); // Dark blue background

    // --- Camera & Lighting ---
    const camera = new BABYLON.FreeCamera("camera", new BABYLON.Vector3(0, 6, -12), scene);
    camera.setTarget(new BABYLON.Vector3(0, 2, 0));

    const light = new BABYLON.DirectionalLight("dirLight", new BABYLON.Vector3(-0.1, -1, 0.2), scene);
    light.position = new BABYLON.Vector3(0, 15, -15);
    light.intensity = 1.2;

    // --- Glow Effect --- //
    const glowLayer = new BABYLON.GlowLayer("glow", scene);
    glowLayer.intensity = 1.5;

    // --- Shadow Generator --- //
    const shadowGenerator = new BABYLON.ShadowGenerator(1024, light);
    shadowGenerator.useBlurExponentialShadowMap = true;

    // --- Materials --- //
    const playerMaterial = new BABYLON.StandardMaterial("playerMat", scene);
    playerMaterial.diffuseColor = new BABYLON.Color3.FromHexString("#e74c3c"); // Bright red

    const obstacleMaterial = new BABYLON.StandardMaterial("obstacleMat", scene);
    obstacleMaterial.diffuseColor = new BABYLON.Color3.FromHexString("#9b59b6"); // Purple

    const coinMaterial = new BABYLON.StandardMaterial("coinMat", scene);
    coinMaterial.emissiveColor = new BABYLON.Color3.FromHexString("#f1c40f"); // Yellow glow

    // --- Player --- //
    const player = BABYLON.MeshBuilder.CreateSphere("player", {diameter: 1.5}, scene);
    player.position.y = 0.75;
    player.material = playerMaterial;
    shadowGenerator.addShadowCaster(player);

    const lanes = [-3, 0, 3];
    let currentLane = 1;
    player.position.x = lanes[currentLane];

    // --- Ground --- //
    const ground = BABYLON.MeshBuilder.CreateGround("ground", {width: 10, height: 250}, scene);
    const groundMaterial = new BABYLON.StandardMaterial("groundMat", scene);
    const gridTexture = new BABYLON.GridMaterial("gridMat", scene);
    gridTexture.mainColor = new BABYLON.Color3.FromHexString("#34495e");
    gridTexture.lineColor = new BABYLON.Color3.FromHexString("#7f8c8d");
    ground.material = gridTexture;
    ground.position.z = 80;
    ground.receiveShadows = true;

    // --- Object Pooling --- //
    let obstaclePool = [];
    let coinPool = [];
    const POOL_SIZE = 15;

    for (let i = 0; i < POOL_SIZE; i++) {
        let obstacle;
        if (Math.random() > 0.5) {
            obstacle = BABYLON.MeshBuilder.CreateBox(`obstacle${i}`, {size: 2}, scene);
        } else {
            obstacle = BABYLON.MeshBuilder.CreateCylinder(`obstacle${i}`, {height: 2, diameter: 2}, scene);
        }
        obstacle.material = obstacleMaterial;
        obstacle.setEnabled(false);
        shadowGenerator.addShadowCaster(obstacle);
        obstaclePool.push(obstacle);

        const coin = BABYLON.MeshBuilder.CreateSphere(`coin${i}`, {diameter: 1}, scene);
        coin.material = coinMaterial;
        coin.setEnabled(false);
        coinPool.push(coin);
    }

    function spawnObjects() {
        let lastLane = -1;

        // Disable all objects first
        obstaclePool.forEach(o => o.setEnabled(false));
        coinPool.forEach(c => c.setEnabled(false));

        for (let i = 0; i < POOL_SIZE; i++) {
            let lane;
            do {
                lane = Math.floor(Math.random() * 3);
            } while (lane === lastLane); // Avoid placing objects in the same lane twice in a row
            lastLane = lane;

            const zPos = 30 + i * 18;

            if (Math.random() > 0.4) { // Spawn obstacle
                const obstacle = obstaclePool[i];
                obstacle.position = new BABYLON.Vector3(lanes[lane], 1, zPos);
                obstacle.setEnabled(true);
            } else { // Spawn coin
                const coin = coinPool[i];
                coin.position = new BABYLON.Vector3(lanes[lane], 1, zPos);
                coin.setEnabled(true);
            }
        }
    }

    spawnObjects();

    // --- Controls --- //
    // Keyboard
    window.addEventListener('keydown', (event) => {
        if (!isGameRunning) return;
        if (event.key === 'ArrowLeft') moveLane(-1);
        if (event.key === 'ArrowRight') moveLane(1);
    });

    // Swipe
    let touchStartX = 0;
    window.addEventListener('touchstart', (event) => {
        touchStartX = event.touches[0].clientX;
    });

    window.addEventListener('touchmove', (event) => {
        if (!isGameRunning || !touchStartX) return;
        const touchEndX = event.touches[0].clientX;
        const diff = touchEndX - touchStartX;

        if (Math.abs(diff) > 50) { // Swipe threshold
            if (diff > 0) moveLane(1);
            else moveLane(-1);
            touchStartX = 0; // Reset after swipe
        }
    });

    function moveLane(direction) {
        const newLane = currentLane + direction;
        if (newLane >= 0 && newLane < lanes.length) {
            currentLane = newLane;
            BABYLON.Animation.CreateAndStartAnimation('laneAnim', player, 'position.x', 30, 10, player.position.x, lanes[currentLane], BABYLON.Animation.ANIMATIONLOOPMODE_CONSTANT);
        }
    }

    // --- Game Over & Restart ---
    restartButton.addEventListener('click', () => location.reload());
    continueButton.addEventListener('click', () => sendToFlutter("watchAdToContinue"));

    // --- Game Loop Actions ---
    const gameSpeed = 0.5;
    scene.onBeforeRenderObservable.add(() => {
        if (!isGameRunning) return;

        // Animate ground texture
        gridMaterial.gridOffset.y += gameSpeed * 0.05;

        obstaclePool.forEach(o => {
            if (o.isEnabled()) {
                o.position.z -= gameSpeed;
                if (o.position.z < -10) o.setEnabled(false);
                if (!isPlayerInvincible && player.intersectsMesh(o, false)) {
                    isGameRunning = false;
                    gameOverScreen.style.display = 'flex';
                }
            }
        });

        coinPool.forEach(c => {
            if (c.isEnabled()) {
                c.position.z -= gameSpeed;
                if (c.position.z < -10) c.setEnabled(false);
                if (player.intersectsMesh(c, false)) {
                    coinManager.collectCoin();
                    c.setEnabled(false);
                }
            }
        });

        // Reset ground and respawn objects
        if (ground.position.z < -125) {
            ground.position.z = 125;
            spawnObjects();
        }
        ground.position.z -= gameSpeed;
    });

    return scene;
}

const scene = createScene();

engine.runRenderLoop(() => {
    scene.render();
});

window.addEventListener('resize', () => {
    engine.resize();
});
