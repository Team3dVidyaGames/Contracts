# AgnosiaGame
[Git Source](https://github.com//Team3dVidyaGames/Contracts/blob/edd5b9280854f5d7be315ec63c3c3a058db024c0/src/contracts/agnosia/AgnosiaGame.sol)

**Inherits:**
ReentrancyGuard


## State Variables
### token

```solidity
IERC20 public immutable token;
```


### cards

```solidity
ITCGInventory public immutable cards;
```


### playersDeck

```solidity
mapping(address => uint256[]) public playersDeck;
```


### tokenIdToCard

```solidity
mapping(uint256 => Card) public tokenIdToCard;
```


### playerGames

```solidity
mapping(address => uint256[]) public playerGames;
```


### gamesPlayed

```solidity
mapping(uint256 => GamePlay) public gamesPlayed;
```


### directRulePrizes

```solidity
mapping(address => mapping(uint256 => uint256[])) public directRulePrizes;
```


### playerData

```solidity
mapping(address => Player) public playerData;
```


### isPlayerAdded

```solidity
mapping(address => bool) public isPlayerAdded;
```


### gameStartBlock

```solidity
mapping(uint256 => uint256) public gameStartBlock;
```


### friendGames

```solidity
mapping(uint256 => address) public friendGames;
```


### gameSumRequired

```solidity
mapping(uint256 => uint8) public gameSumRequired;
```


### allPlayers

```solidity
address[] public allPlayers;
```


### gamesWaitingPlayer

```solidity
uint256[] public gamesWaitingPlayer;
```


### forfeitTimers

```solidity
uint256[6] public forfeitTimers = [5 minutes, 15 minutes, 30 minutes, 1 hours, 12 hours, 24 hours];
```


### gameIndexToTimerRule

```solidity
mapping(uint256 => uint256) public gameIndexToTimerRule;
```


### gamesCreated

```solidity
uint256 public gamesCreated;
```


### minimumWager

```solidity
uint256 public minimumWager;
```


### spots

```solidity
uint8[4][9] spots = [
    [9, 9, 3, 1],
    [9, 0, 4, 2],
    [9, 1, 5, 9],
    [0, 9, 6, 4],
    [1, 3, 7, 5],
    [2, 4, 8, 9],
    [3, 9, 9, 7],
    [4, 6, 9, 8],
    [5, 7, 9, 9]
];
```


## Functions
### constructor


```solidity
constructor(address _token, address _cards);
```

### initializeGame

*function user calls to start a game*


```solidity
function initializeGame(
    uint256[5] memory tokenIdOfCardsToPlay,
    uint256 wager,
    uint8 tradeRule,
    address _friend,
    bool limitLevels,
    uint8 levelsAbove,
    uint256 _timerRule
) external nonReentrant;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenIdOfCardsToPlay`|`uint256[5]`|array of the tokenIds in the players deck|
|`wager`|`uint256`|the amount of token they wish to wage if any|
|`tradeRule`|`uint8`|what the winner gets when the game ends|
|`_friend`|`address`|specific player2 address the creator wishes to play with. Zero address means open to any|
|`limitLevels`|`bool`|bool whether or not limit card level cap that can be in player2 hand|
|`levelsAbove`|`uint8`|optional levels cap for player2 (sum of levels in hand)|
|`_timerRule`|`uint256`||


### _buildHand

*function to build the hand for the new game*


```solidity
function _buildHand(uint256[5] memory tokenIdOfCardsToPlay, address user, uint256 index) internal returns (uint8 sum);
```

### joinGame

*function to allow users to join games that need a player*


```solidity
function joinGame(uint256[5] memory tokenIdOfCardsToPlay, uint256 gameWaitingIndex, address creator)
    external
    nonReentrant;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenIdOfCardsToPlay`|`uint256[5]`||
|`gameWaitingIndex`|`uint256`|the location in the array of the game they want to play|
|`creator`|`address`|a secondary check to ensure that the gameWaitingIndex selected matches what the caller wants|


### _removeFromWaiting

*function to remove game from waiting List*


```solidity
function _removeFromWaiting(uint256 gameWaitingIndex, uint256 gameIndex) internal;
```

### cancelGameWaiting

*allows a game creator to cancel the current game in waiting if noone has joined*


```solidity
function cancelGameWaiting(uint256 gameWaitingIndex) external;
```

### transferToDeck

*transfer Cards from user into contract and into the deck of the user*


```solidity
function transferToDeck(uint256[] memory tokenIds) external nonReentrant;
```

### _addToDeck

*function adds card to players deck*


```solidity
function _addToDeck(address user, uint256 tokenId) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`user`|`address`|deck to add to|
|`tokenId`|`uint256`|nft ID|


### transferFromDeck

*function to transfer cards from deck to owners wallet*


```solidity
function transferFromDeck(uint256[] memory tokenIds) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenIds`|`uint256[]`|cards to transfer|


### _removeFromDeck

*internal function to remove cards from a players deck*


```solidity
function _removeFromDeck(address user, uint256 tokenId) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`user`|`address`|the current owner|
|`tokenId`|`uint256`|card to remove|


### placeCardOnBoard

*function to play a card*


```solidity
function placeCardOnBoard(uint256 indexInHand, uint256 gameIndex, uint8 boardPosition) external nonReentrant;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`indexInHand`|`uint256`|refers to the card index in the players hand for the game|
|`gameIndex`|`uint256`|refers to the game being played|
|`boardPosition`|`uint8`|refers to where the card is to be placed|


### canFinalizeGame


```solidity
function canFinalizeGame(address user, uint256 gameIndex) public view returns (bool);
```

### collectWinnings

*function for end of game state where the winner can claim, if draw either can claim*


```solidity
function collectWinnings(uint256 gameIndex, uint256[] memory cardsToClaimTokenIds) external nonReentrant;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`gameIndex`|`uint256`|refers to game|
|`cardsToClaimTokenIds`|`uint256[]`|used to claim cards if not draw or direct|


### forfeitReturn


```solidity
function forfeitReturn(uint256 gameIndex, address user, address other) internal;
```

### drawReturnCardsFromBoard

*function to return cards in case of draw*


```solidity
function drawReturnCardsFromBoard(uint256 gameIndex, address other, address user) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`gameIndex`|`uint256`|game instance|
|`other`|`address`|non-msg.sender|
|`user`|`address`|msg.sender|


### directReturnCards

*function to return cards in case of direct trade rule*


```solidity
function directReturnCards(uint256 gameIndex, address user) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`gameIndex`|`uint256`|game instance|
|`user`|`address`|msg.sender and winner|


### _transferCard

*function to transfer card in deck from one owner to another*


```solidity
function _transferCard(uint256 tokenId, uint256 gameIndex, address newOwner, address currentOwner) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|card to transfer|
|`gameIndex`|`uint256`|game associated with the transfer|
|`newOwner`|`address`|new owner of card|
|`currentOwner`|`address`|current owner of card|


### updateCards

*function to update cards from game and to make them active in deck again*


```solidity
function updateCards(uint256 win, uint256 tokenId) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`win`|`uint256`|0 if loss or 1 if card won|
|`tokenId`|`uint256`|card to update|


### returnCards

*function to return cards*


```solidity
function returnCards(uint256 gameIndex, address other, address user, uint256[] memory cardsToClaimTokenIds) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`gameIndex`|`uint256`|game instance|
|`other`|`address`|non-msg.sender|
|`user`|`address`|msg.sender and winner|
|`cardsToClaimTokenIds`|`uint256[]`|winner card claim|


### registerId

*Registers a Discord ID to the calling player's address.
Throws an error if the player has already registered a Discord ID.*


```solidity
function registerId(uint64 _discordId) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_discordId`|`uint64`|The Discord ID to be registered.|


### updatePfp


```solidity
function updatePfp(address _nft, uint256 _tokenId) external;
```

### _assignScore

*Increments the win count for the winner and the loss count for the loser.*


```solidity
function _assignScore(address _winner, address _loser) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_winner`|`address`|The address of the player who won the game.|
|`_loser`|`address`|The address of the player who lost the game.|


### _addUniquePlayer


```solidity
function _addUniquePlayer(address _player) internal;
```

### getTop10Players


```solidity
function getTop10Players() public view returns (address[] memory);
```

### deckInfo

*function to view deck*


```solidity
function deckInfo(address player) external view returns (uint256 size, uint256[] memory deck);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`player`|`address`|check players deck|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`size`|`uint256`|the number of cards in deck|
|`deck`|`uint256[]`|the tokenIds of cards in deck|


### gamesNeedPlayer

*function to return game Indexes*


```solidity
function gamesNeedPlayer() external view returns (uint256[] memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256[]`|game index array|


### getGameDetails

*Fetches the data of a game.*


```solidity
function getGameDetails(uint256 gameID)
    public
    view
    returns (
        Card[9] memory,
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        uint8,
        uint8,
        bool,
        bool,
        uint256,
        uint8,
        uint256
    );
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`gameID`|`uint256`|The ID of the game to fetch.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`Card[9]`|board The current game board.|
|`<none>`|`address`|player1 The first player's address.|
|`<none>`|`address`|player2 The second player's address.|
|`<none>`|`uint256[]`|player1Hand The first player's hand.|
|`<none>`|`uint256[]`|player2Hand The second player's hand.|
|`<none>`|`uint8`|player1Points The first player's points.|
|`<none>`|`uint8`|player2Points The second player's points.|
|`<none>`|`bool`|isTurn Indicates whether it's player 1's turn or not.|
|`<none>`|`bool`|gameFinished Indicates whether the game is finished or not.|
|`<none>`|`uint256`|wager The wager of the game.|
|`<none>`|`uint8`|tradeRule The trading rule being used in the game.|
|`<none>`|`uint256`|lastMove The timestamp of the last move.|


### playerGamesPlayed

*returns gameIndexes that player is current involved in and finished*


```solidity
function playerGamesPlayed(address player) external view returns (uint256[] memory gamesIndexes);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`player`|`address`|address to check|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`gamesIndexes`|`uint256[]`|a list of indexes|


### forfeit

*function to see if game was forfeited by a player*


```solidity
function forfeit(uint256 gameIndex) public view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`gameIndex`|`uint256`|the game in query of|


### finalized

*function to see if game is finalized meaning no more moves left AND winnings are also claimed.*


```solidity
function finalized(uint256 gameIndex) public view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`gameIndex`|`uint256`|the game in query of|


### getStartingHand

*function to fetch starting hands for players in a specific gameId*


```solidity
function getStartingHand(address _player, uint256 _gameId) external view returns (uint256[] memory _startingHand);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_player`|`address`|is the player we are interested in|
|`_gameId`|`uint256`|is the gameId we are interested in|


### getDepositedAvailableCards

*Fetches the deposited cards available for a player.*


```solidity
function getDepositedAvailableCards(address _player) external view returns (uint256[] memory _tokenIds);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_player`|`address`|The address of the player whose available cards we want to fetch.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`_tokenIds`|`uint256[]`|An array containing the token IDs of the cards that are available.|


### getActivePlayerGames

*Fetches a list of active (non-finalized) game IDs for a given player.*


```solidity
function getActivePlayerGames(address _player) external view returns (uint256[] memory _gameIds);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_player`|`address`|The address of the player.|


## Events
### GameInitialized

```solidity
event GameInitialized(
    uint256 indexed _gameId,
    uint256[5] _tokenIdOfCardsToPlay,
    uint256 _wager,
    uint8 _tradeRule,
    address _friend,
    uint256 timerRule
);
```

### JoinedGame

```solidity
event JoinedGame(address _whoJoined, address _whoseGame, uint256 indexed _gameId, uint256[5] _tokenIdOfCardsToPlay);
```

### CardPlacedOnBoard

```solidity
event CardPlacedOnBoard(
    uint256 _tokenId, uint256 indexed _gameIndex, uint8 _boardPosition, bool[4] same, uint8[4] plus
);
```

### CollectWinnings

```solidity
event CollectWinnings(uint256 indexed gameId, address winner, address loser, uint256[] prize, uint256 bet, bool draw);
```

### directCards

```solidity
event directCards(
    uint256 indexed gameIndex, address player1, address player2, uint256[] directPrize1, uint256[] directPrize2
);
```

### GameCanceled

```solidity
event GameCanceled(uint256 indexed gameIndex);
```

### CardCaptured

```solidity
event CardCaptured(uint256 tokenId, uint8 boardPosition);
```

## Structs
### Card

```solidity
struct Card {
    uint256 tokenID;
    uint8[4] powers;
    address owner;
    uint256 userIndex;
    uint256 currentGameIndex;
    uint8 level;
}
```

### GamePlay

```solidity
struct GamePlay {
    Card[9] board;
    address player1;
    address player2;
    mapping(address => uint256[]) playerHand;
    mapping(address => uint256[]) startingHand;
    mapping(address => uint8) points;
    bool isTurn;
    bool gameFinished;
    uint256 wager;
    uint8 tradeRule;
    uint256 lastMove;
    bool isFinalized;
    uint256[] prizeCollected;
}
```

### Player

```solidity
struct Player {
    address _nft;
    uint256 _tokenId;
    uint64 _discordId;
    uint32 _wins;
    uint32 _losses;
}
```

