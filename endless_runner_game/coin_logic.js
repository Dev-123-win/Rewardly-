// --- Coin Economy Configuration --- //
// This file separates the game's economy for easy editing.

// The value of a single coin collected in the game.
const COIN_VALUE = 1; 

// How many points the player gets in the Flutter app for each batch of coins.
const FLUTTER_REWARD_AMOUNT = 10; 

// How many coins the player must collect before we send a message to Flutter.
// This is a Firebase optimization: we write to the database once per 10 coins,
// not for every single coin collected.
const COIN_BATCH_SIZE = 10;

// This object will keep track of the player's current coin count within a batch.
const coinManager = {
    currentCoins: 0,

    // Call this function every time the player collects a coin.
    collectCoin: function() {
        this.currentCoins += COIN_VALUE;

        // Check if the batch is complete
        if (this.currentCoins >= COIN_BATCH_SIZE) {
            // Send a message to the Flutter app to add the points
            sendToFlutter(`addPoints:${FLUTTER_REWARD_AMOUNT}`);
            
            // Reset the counter for the next batch
            this.currentCoins = 0;
        }
    }
};
