// --- Coin Economy Configuration --- //

// The value of a single coin collected in the game.
const COIN_VALUE = 1;

// How many coins the player must collect before we send a message to Flutter.
// This is a Firebase optimization: we write to the database once per batch,
// not for every single coin collected.
const COIN_BATCH_SIZE = 20;

const coinManager = {
    currentCoinsInBatch: 0,
    collectedCoinIds: new Set(),

    collectCoin: function(coinId) {
        // Avoid double-counting coins that are still on screen after a reset
        if (this.collectedCoinIds.has(coinId)) {
            return; 
        }

        this.collectedCoinIds.add(coinId);
        this.currentCoinsInBatch += COIN_VALUE;

        // When the batch is full, send the total to Flutter
        if (this.currentCoinsInBatch >= COIN_BATCH_SIZE) {
            sendToFlutter(`gameCoinsCollected:${this.currentCoinsInBatch}`);
            
            // Reset for the next batch
            this.currentCoinsInBatch = 0;
        }
    },

    // Reset the manager when the game restarts
    reset: function() {
        this.currentCoinsInBatch = 0;
        this.collectedCoinIds.clear();
    }
};