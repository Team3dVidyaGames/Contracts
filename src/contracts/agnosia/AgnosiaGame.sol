// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7 <0.9.0;

/*
  _______                   ____  _____  
 |__   __|                 |___ \|  __ \ 
    | | ___  __ _ _ __ ___   __) | |  | |
    | |/ _ \/ _` | '_ ` _ \ |__ <| |  | |
    | |  __/ (_| | | | | | |___) | |__| |
    |_|\___|\__,_|_| |_| |_|____/|_____/ 

    https://team3d.io
    https://discord.gg/team3d
    TCG 
    
    @author Team3d.R&D
 */
import "../../../lib/openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "../../../lib/openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../interfaces/ITCGInventory.sol";

contract AgnosiaGame is ReentrancyGuard {
    using SafeERC20 for IERC20;

    IERC20 public immutable token;
    ITCGInventory public immutable cards;
    IERC721 public immutable items;

    struct Card {
        uint256 tokenID;
        uint8[4] powers; // 0 top, 1 left, 2 bottom, 3 right
        address owner;
        uint256 userIndex;
        uint256 currentGameIndex; // index 0 means not in game
        uint8 level;
    }

    struct GamePlay {
        Card[9] board;
        address player1;
        address player2;
        mapping(address => uint256[]) playerHand;
        mapping(address => uint256[]) startingHand;
        mapping(address => uint8) points;
        bool isTurn; // false player1 turn, true player2 turn
        bool gameFinished;
        uint256 wager;
        uint8 tradeRule; // 0 = one card, 1 = Difference, 2 = Direct, 3 = All
        uint256 lastMove; // tracks last move, preventing the loser from holding game hostage
        bool isFinalized;
        uint256[] prizeCollected;
    }

    struct Player {
        uint256 _pfpArrayLength;
        uint64 _discordId;
        uint32 _wins;
        uint32 _losses;
    }

    struct Pfp {
        address _nft;
        uint256 _tokenId;
    }

    mapping(address => uint256[]) public playersDeck; // tokenId instorage on contract
    mapping(uint256 => Card) public tokenIdToCard;
    mapping(address => uint256[]) public playerGames;
    mapping(uint256 => GamePlay) public gamesPlayed;
    mapping(address => mapping(uint256 => uint256[])) public directRulePrizes;
    mapping(address => Player) public playerData;
    mapping(address => Pfp[]) playerPfP;
    mapping(address => bool) public isPlayerAdded;
    mapping(uint256 => uint256) public gameStartBlock;
    mapping(uint256 => address) public friendGames; // gameIds reserved for specific player2's
    mapping(uint256 => uint8) public gameSumRequired; // card level sums (if set) required to join a game

    address[] public allPlayers; // List of all players who ever played
    uint256[] public gamesWaitingPlayer;

    uint256[6] public forfeitTimers = [5 minutes, 15 minutes, 30 minutes, 1 hours, 12 hours, 24 hours]; // timers limit when players need to make a move or lose otherwise
    mapping(uint256 => uint256) public gameIndexToTimerRule;
    uint256 public gamesCreated;
    uint256 public minimumWager;

    //top, left, bottom, right
    //0,1,2
    //3,4,5
    //6,7,8
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
    ]; // used for the board, 9 is out of bounds

    constructor(address _token, address _cards, address _items) {
        token = IERC20(_token); // Vidya
        cards = ITCGInventory(_cards); // Agnosia cards
        items = IERC721(_items); // TeamOS inventory
        minimumWager = 1 ether;
    }

    // Events
    event GameInitialized(
        uint256 indexed _gameId,
        uint256[5] _tokenIdOfCardsToPlay,
        uint256 _wager,
        uint8 _tradeRule,
        address _friend,
        uint256 timerRule
    );
    event JoinedGame(address _whoJoined, address _whoseGame, uint256 indexed _gameId, uint256[5] _tokenIdOfCardsToPlay);
    event CardPlacedOnBoard(
        uint256 _tokenId, uint256 indexed _gameIndex, uint8 _boardPosition, bool[4] same, uint8[4] plus
    );
    event CollectWinnings(
        uint256 indexed gameId, address winner, address loser, uint256[] prize, uint256 bet, bool draw
    );
    event directCards(
        uint256 indexed gameIndex, address player1, address player2, uint256[] directPrize1, uint256[] directPrize2
    );
    event GameCanceled(uint256 indexed gameIndex);
    event CardCaptured(uint256 tokenId, uint8 boardPosition);

    /**
     * @dev function user calls to start a game
     * @param tokenIdOfCardsToPlay array of the tokenIds in the players deck
     * @param wager the amount of token they wish to wage if any
     * @param tradeRule what the winner gets when the game ends
     * @param _friend specific player2 address the creator wishes to play with. Zero address means open to any
     * @param limitLevels bool whether or not limit card level cap that can be in player2 hand
     * @param levelsAbove optional levels cap for player2 (sum of levels in hand)
     */
    function initializeGame(
        uint256[5] memory tokenIdOfCardsToPlay,
        uint256 wager,
        uint8 tradeRule,
        address _friend,
        bool limitLevels,
        uint8 levelsAbove,
        uint256 _timerRule
    ) external nonReentrant {
        require(tradeRule < 4, "tradeRule out of bounds"); // 0 - one; 1 - diff; 2 - direct; 3 - all;
        require(_timerRule < forfeitTimers.length, "Timer out of Bounds");

        uint256 gameId = gamesCreated + 1;
        address user = msg.sender;

        GamePlay storage gp = gamesPlayed[gameId];

        // If friend address was set make it friend only game
        if (_friend != address(0)) {
            friendGames[gameId] = _friend;
        }

        if (wager >= minimumWager) {
            token.safeTransferFrom(user, address(this), wager);
            gp.wager = wager;
        }

        gameSumRequired[gameId] = _buildHand(tokenIdOfCardsToPlay, user, gameId);
        if (limitLevels) {
            gameSumRequired[gameId] += levelsAbove;
        } else {
            gameSumRequired[gameId] = 128; // max card sum is less then 100
        }

        gp.player1 = user;
        gp.tradeRule = tradeRule;
        gameIndexToTimerRule[gameId] = forfeitTimers[_timerRule];

        gamesCreated = gameId;
        gamesWaitingPlayer.push(gameId);

        emit GameInitialized(gameId, tokenIdOfCardsToPlay, wager, tradeRule, _friend, _timerRule);
    }

    /**
     * @dev function to build the hand for the new game
     */
    function _buildHand(uint256[5] memory tokenIdOfCardsToPlay, address user, uint256 index)
        internal
        returns (uint8 sum)
    {
        GamePlay storage gp = gamesPlayed[index];

        for (uint256 x = 0; x < 5;) {
            require(cards.ownerOf(tokenIdOfCardsToPlay[x]) == address(this), "Deposit Card First");
            Card storage c = tokenIdToCard[tokenIdOfCardsToPlay[x]];
            require(c.owner == user, "Not the owner of Card");
            require(c.currentGameIndex == 0, "Card is already in game");

            sum += c.level;
            c.currentGameIndex = index; // stops card from being transferred
            gp.playerHand[user].push(tokenIdOfCardsToPlay[x]);
            gp.startingHand[user].push(tokenIdOfCardsToPlay[x]);
            gp.points[user]++;

            unchecked {
                x++;
            }
        }

        playerGames[user].push(index);
    }

    /**
     * @dev function to allow users to join games that need a player
     * @param gameWaitingIndex the location in the array of the game they want to play
     * @param creator a secondary check to ensure that the gameWaitingIndex selected matches what the caller wants
     */
    function joinGame(uint256[5] memory tokenIdOfCardsToPlay, uint256 gameWaitingIndex, address creator)
        external
        nonReentrant
    {
        uint256 gameIndex = gamesWaitingPlayer[gameWaitingIndex];
        address user = msg.sender;

        // Check if it's a public game or a friend game
        require(friendGames[gameIndex] == address(0) || friendGames[gameIndex] == msg.sender, "Not a fren, sorry!");

        GamePlay storage gp = gamesPlayed[gameIndex];

        require(user != creator, "Can't join your own game");
        require(gp.player1 == creator, "Creator mismatch");
        require(gp.player2 == address(0), "Game already taken");

        if (gp.wager >= minimumWager) {
            token.safeTransferFrom(user, address(this), gp.wager);
        }

        gp.player2 = user;

        // For when creators set card level caps for games
        uint8 sum = _buildHand(tokenIdOfCardsToPlay, user, gameIndex); // sum of levels of cards in hand
        require(sum <= gameSumRequired[gameIndex], "Card levels are too high for this game.");

        gp.lastMove = block.timestamp;
        _removeFromWaiting(gameWaitingIndex, gameIndex);

        // Add gameStartBlock (when did this game start?)
        gameStartBlock[gameIndex] = block.number;

        emit JoinedGame(user, creator, gameIndex, tokenIdOfCardsToPlay);
    }

    /**
     * @dev function to remove game from waiting List
     */
    function _removeFromWaiting(uint256 gameWaitingIndex, uint256 gameIndex) internal {
        uint256 lastOne = gamesWaitingPlayer.length - 1;
        require(gamesWaitingPlayer[gameWaitingIndex] == gameIndex, "Game Index does not match waiting list");

        gamesWaitingPlayer[gameWaitingIndex] = gamesWaitingPlayer[lastOne];
        gamesWaitingPlayer.pop();
    }

    /**
     * @dev allows a game creator to cancel the current game in waiting if noone has joined
     */
    function cancelGameWaiting(uint256 gameWaitingIndex) external {
        require(gameWaitingIndex < gamesWaitingPlayer.length, "Out of bounds");
        GamePlay storage gp = gamesPlayed[gamesWaitingPlayer[gameWaitingIndex]];
        address user = msg.sender;
        require(gp.player1 == user, "Caller must be creator");
        require(gp.player2 == address(0), "Game already has two players");

        if (gp.wager > 0) {
            token.safeTransfer(user, gp.wager);
            gp.wager = 0;
        }

        for (uint256 x = 0; x < 5;) {
            tokenIdToCard[gp.playerHand[user][x]].currentGameIndex = 0; // Makes card tradeable
            unchecked {
                x++;
            }
        }

        _removeFromWaiting(gameWaitingIndex, gamesWaitingPlayer[gameWaitingIndex]);

        gp.gameFinished = true;
        gp.isFinalized = true;

        emit GameCanceled(gameWaitingIndex);
    }

    /**
     * @dev transfer Cards from user into contract and into the deck of the user
     */
    function transferToDeck(uint256[] memory tokenIds) external nonReentrant {
        uint256 l = tokenIds.length;
        address user = msg.sender;

        for (uint256 x = 0; x < l;) {
            uint256 id = tokenIds[x];
            require(cards.ownerOf(id) == user, "Sender must be owner");
            cards.transferFrom(user, address(this), id);
            _addToDeck(user, tokenIds[x]);
            unchecked {
                x++;
            }
        }
    }

    /**
     * @dev function adds card to players deck
     * @param user deck to add to
     * @param tokenId nft ID
     */
    function _addToDeck(address user, uint256 tokenId) internal {
        Card memory c;
        c.tokenID = tokenId;
        // top          left         right        bottom
        (c.level, c.powers[0], c.powers[1], c.powers[3], c.powers[2],,,) = cards.dataReturn(tokenId);
        c.owner = user;
        c.userIndex = playersDeck[user].length;
        playersDeck[user].push(tokenId);
        tokenIdToCard[tokenId] = c;
    }

    /**
     * @dev function to transfer cards from deck to owners wallet
     * @param tokenIds cards to transfer
     */
    function transferFromDeck(uint256[] memory tokenIds) external {
        address user = msg.sender;
        uint256 l = tokenIds.length;
        require(l <= playersDeck[user].length, "Out of bounds");

        for (uint256 x = 0; x < l;) {
            require(tokenIdToCard[tokenIds[x]].owner == user, "Not owner");
            require(tokenIdToCard[tokenIds[x]].currentGameIndex == 0, "Card in Game Currently");
            _removeFromDeck(user, tokenIds[x]);
            cards.transferFrom(address(this), user, tokenIds[x]);

            unchecked {
                x++;
            }
        }
    }

    /**
     * @dev internal function to remove cards from a players deck
     * @param user the current owner
     * @param tokenId card to remove
     */
    function _removeFromDeck(address user, uint256 tokenId) internal {
        Card storage c = tokenIdToCard[tokenId];
        uint256 y = playersDeck[user].length - 1;
        uint256 c1I = c.userIndex;
        c.currentGameIndex = 0;
        c.userIndex = 0;
        c.owner = address(0);

        playersDeck[user][c1I] = playersDeck[user][y];
        tokenIdToCard[playersDeck[user][y]].userIndex = c1I;
        playersDeck[user].pop();
    }

    /**
     * @dev function to play a card
     * @param indexInHand refers to the card index in the players hand for the game
     * @param gameIndex refers to the game being played
     * @param boardPosition refers to where the card is to be placed
     */
    function placeCardOnBoard(uint256 indexInHand, uint256 gameIndex, uint8 boardPosition) external nonReentrant {
        GamePlay storage game = gamesPlayed[gameIndex];
        address user = msg.sender;
        require(!game.isFinalized, "Game already finalized");
        require(game.player2 != address(0), "No second player yet");
        bool canPlay = (game.player1 == user && !game.isTurn) || (game.player2 == user && game.isTurn); // is a users turn
        require(canPlay, "Not a player or turn yet");
        require(boardPosition < 9, "Position out of bounds");
        require(game.board[boardPosition].owner == address(0), "Position already taken");
        require(game.playerHand[user].length > indexInHand, "Hand out of bounds");

        game.isTurn = !game.isTurn;
        uint256 tokenId = game.playerHand[user][indexInHand];
        game.playerHand[user][indexInHand] = game.playerHand[user][game.playerHand[user].length - 1];
        game.playerHand[user].pop();
        game.board[boardPosition] = tokenIdToCard[tokenId];

        uint8[4] memory otherPos = spots[boardPosition];
        uint8[4] memory sum;
        bool[4] memory same;
        bool[4] memory indexToChange;
        uint8 sameCount;

        for (uint8 i = 0; i < 4;) {
            uint8 pos = otherPos[i];
            if (pos < 9) {
                // pos is on the board
                if (game.board[pos].owner != address(0)) {
                    // there is a card placed on the board at pos
                    uint8 a = game.board[boardPosition].powers[i];
                    uint8 b = game.board[pos].powers[(i + 2) % 4];
                    sum[i] = a + b;
                    same[i] = a == b;
                    if (a == b) {
                        sameCount++;
                    }
                    if (a > b) {
                        indexToChange[i] = true;
                    }
                }
            }
            unchecked {
                i++;
            }
        }

        (uint8[4] memory ar, bool truth) = putma.sumFind(sum);

        if (truth || sameCount > 1) {
            bool sT = sameCount > 1;
            for (uint8 i = 0; i < 4;) {
                // Found Sum Match at index
                if (ar[i] > 0) {
                    indexToChange[ar[i]] = true;
                    indexToChange[i] = true;
                }
                //if true
                if (same[i] && sT) {
                    indexToChange[i] = true;
                }

                unchecked {
                    i++;
                }
            }
        }

        address other = game.player1;
        if (other == user) {
            other = game.player2;
        }
        for (uint8 i = 0; i < 4;) {
            if (indexToChange[i] && game.board[otherPos[i]].owner == other) {
                game.board[otherPos[i]].owner = user;
                game.points[other] -= 1;
                game.points[user] += 1;

                // Emit the event for the card capture
                emit CardCaptured(game.board[otherPos[i]].tokenID, otherPos[i]);
            }

            unchecked {
                i++;
            }
        }
        game.lastMove = block.timestamp;
        // Game is finished if a players hand == 0
        game.gameFinished = game.playerHand[user].length == 0;

        emit CardPlacedOnBoard(tokenId, gameIndex, boardPosition, same, ar);
    }

    function canFinalizeGame(address user, uint256 gameIndex) public view returns (bool) {
        bool canClaim = false;

        if (user == gamesPlayed[gameIndex].player1 || user == gamesPlayed[gameIndex].player2) {
            if (gamesPlayed[gameIndex].gameFinished) {
                address other = gamesPlayed[gameIndex].player1;
                if (other == user) {
                    other = gamesPlayed[gameIndex].player2;
                }
                canClaim = gamesPlayed[gameIndex].points[user] >= gamesPlayed[gameIndex].points[other]; //is Winner

                if (gamesPlayed[gameIndex].lastMove > block.timestamp - gameIndexToTimerRule[gameIndex]) {
                    //If finished for more then the timer rule the loser can finalize can finalize
                    canClaim = true;
                }
            }
            canClaim = canClaim || forfeit(gameIndex);
        }

        return canClaim;
    }

    /**
     * @dev function for end of game state where the winner can claim, if draw either can claim
     * @param gameIndex refers to game
     * @param cardsToClaimTokenIds used to claim cards if not draw or direct
     */
    function collectWinnings(uint256 gameIndex, uint256[] memory cardsToClaimTokenIds) external nonReentrant {
        address user = msg.sender;
        require(
            user == gamesPlayed[gameIndex].player1 || user == gamesPlayed[gameIndex].player2,
            "Must be a player of the game."
        );
        require(!gamesPlayed[gameIndex].isFinalized, "Already Collected");
        address other = gamesPlayed[gameIndex].player1;

        if (other == user) {
            other = gamesPlayed[gameIndex].player2;
        }

        if (forfeit(gameIndex)) {
            // If forfeit timer is reached then the caller must be the
            require(
                !(gamesPlayed[gameIndex].player1 == user && !gamesPlayed[gameIndex].isTurn)
                    || (gamesPlayed[gameIndex].player2 == user && gamesPlayed[gameIndex].isTurn),
                "Only player whose turn is not it."
            ); // users turn

            gamesPlayed[gameIndex].gameFinished = true;
            forfeitReturn(gameIndex, user, other);
        } else {
            require(gamesPlayed[gameIndex].gameFinished, "Game still playing");

            if ((gamesPlayed[gameIndex].points[user] < gamesPlayed[gameIndex].points[other])) {
                // if not winner finalizing
                require(
                    gamesPlayed[gameIndex].lastMove > block.timestamp - gameIndexToTimerRule[gameIndex],
                    "Loser can only finalize after turn timer is up"
                );
                // need to swap user and other to make logic work for winning and losing.
                user = other; // user is consider winner
                other = msg.sender; // other is considered loser
            }

            if (
                gamesPlayed[gameIndex].points[user] == gamesPlayed[gameIndex].points[other]
                    && gamesPlayed[gameIndex].tradeRule != 2
            ) {
                // if draw
                drawReturnCardsFromBoard(gameIndex, other, user);
            } else if (gamesPlayed[gameIndex].tradeRule != 2) {
                // if not direct tradeRule
                _assignScore(user, other);
                returnCards(gameIndex, other, user, cardsToClaimTokenIds);
            } else {
                // direct trade rule
                _assignScore(user, other);
                directReturnCards(gameIndex, user);
            }

            // Free up cards in users hand
            if (gamesPlayed[gameIndex].playerHand[user].length > 0) {
                for (uint256 i = 0; i < gamesPlayed[gameIndex].playerHand[user].length;) {
                    tokenIdToCard[gamesPlayed[gameIndex].playerHand[user][i]].currentGameIndex = 0;
                    unchecked {
                        i++;
                    }
                }
            }

            // Free up cards in others hand
            if (gamesPlayed[gameIndex].playerHand[other].length > 0) {
                for (uint256 i = 0; i < gamesPlayed[gameIndex].playerHand[other].length;) {
                    tokenIdToCard[gamesPlayed[gameIndex].playerHand[other][i]].currentGameIndex = 0;
                    unchecked {
                        i++;
                    }
                }
            }
        }

        gamesPlayed[gameIndex].isFinalized = true;

        // Add players to allPlayers array if they are new
        _addUniquePlayer(user);
        _addUniquePlayer(other);

        emit CollectWinnings(
            gameIndex,
            user,
            other,
            gamesPlayed[gameIndex].prizeCollected,
            gamesPlayed[gameIndex].wager,
            gamesPlayed[gameIndex].points[user] == gamesPlayed[gameIndex].points[other]
        );
    }

    function forfeitReturn(uint256 gameIndex, address user, address other) internal {
        GamePlay storage g = gamesPlayed[gameIndex];

        for (uint256 i = 0; i < 5;) {
            uint256 tokenId = g.startingHand[other][i];
            _transferCard(tokenId, gameIndex, user, other); // Forfeit player loses all cards.
            g.prizeCollected.push(tokenId);
            updateCards(0, tokenId);
            tokenIdToCard[g.startingHand[user][i]].currentGameIndex = 0; // returns current callers cards.
            updateCards(1, g.startingHand[user][i]);
            unchecked {
                i++;
            }
        }

        _assignScore(user, other);
        token.safeTransfer(user, g.wager * 2);
    }

    /**
     * @dev function to return cards in case of draw
     * @param gameIndex game instance
     * @param other non-msg.sender
     * @param user msg.sender
     */
    function drawReturnCardsFromBoard(uint256 gameIndex, address other, address user) internal {
        GamePlay storage g = gamesPlayed[gameIndex];

        for (uint256 i = 0; i < 9;) {
            updateCards(0, g.board[i].tokenID);
            unchecked {
                i++;
            }
        }

        if (g.wager > 0) {
            token.safeTransfer(user, g.wager);
            token.safeTransfer(other, g.wager);
        }
    }

    /**
     * @dev function to return cards in case of direct trade rule
     * @param gameIndex game instance
     * @param user msg.sender and winner
     */
    function directReturnCards(uint256 gameIndex, address user) internal {
        GamePlay storage g = gamesPlayed[gameIndex];

        for (uint256 i = 0; i < 9;) {
            uint256 tokenId = g.board[i].tokenID;
            uint256 win;
            if (g.board[i].owner == user) {
                win = 1;
            }
            if (g.board[i].owner != tokenIdToCard[tokenId].owner) {
                // if card on board is controlled by winner but not owned
                _transferCard(tokenId, gameIndex, g.board[i].owner, tokenIdToCard[tokenId].owner);
                directRulePrizes[g.board[i].owner][gameIndex].push(tokenId);
            }

            updateCards(win, tokenId);
            unchecked {
                i++;
            }
        }

        if (g.wager > 0) {
            token.safeTransfer(user, gamesPlayed[gameIndex].wager * 2);
        }

        emit directCards(
            gameIndex,
            g.player1,
            g.player2,
            directRulePrizes[g.player1][gameIndex],
            directRulePrizes[g.player2][gameIndex]
        );
    }

    /**
     * @dev function to transfer card in deck from one owner to another
     * @param tokenId card to transfer
     * @param gameIndex game associated with the transfer
     * @param newOwner new owner of card
     * @param currentOwner current owner of card
     */
    function _transferCard(uint256 tokenId, uint256 gameIndex, address newOwner, address currentOwner) internal {
        require(
            tokenIdToCard[tokenId].owner == currentOwner && tokenIdToCard[tokenId].currentGameIndex == gameIndex,
            "Card does not meet requirements"
        );
        _removeFromDeck(currentOwner, tokenId);
        _addToDeck(newOwner, tokenId);
    }

    /**
     * @dev function to update cards from game and to make them active in deck again
     * @param win 0 if loss or 1 if card won
     * @param tokenId card to update
     */
    function updateCards(uint256 win, uint256 tokenId) internal {
        cards.updateCardGameInformation(win, 1, tokenId);
        tokenIdToCard[tokenId].currentGameIndex = 0;
    }

    /**
     * @dev function to return cards
     * @param gameIndex game instance
     * @param other non-msg.sender
     * @param user msg.sender and winner
     * @param cardsToClaimTokenIds winner card claim
     */
    function returnCards(uint256 gameIndex, address other, address user, uint256[] memory cardsToClaimTokenIds)
        internal
    {
        GamePlay storage g = gamesPlayed[gameIndex];

        uint256 cardsToCollect = putma.cardsToCollect(g.tradeRule, g.points[user], g.points[other]);

        if (cardsToCollect > 0) {
            require(cardsToClaimTokenIds.length == cardsToCollect, "length does not match winnings to claim");
            if (g.tradeRule != 2) {
                // !direct
                for (uint256 i = 0; i < cardsToCollect;) {
                    _transferCard(cardsToClaimTokenIds[i], gameIndex, user, other);
                    g.prizeCollected.push(cardsToClaimTokenIds[i]);
                    unchecked {
                        i++;
                    }
                }
            }
        }

        for (uint256 i = 0; i < 9;) {
            uint256 tokenId = g.board[i].tokenID;
            uint256 win;

            if (g.board[i].owner == user) {
                win = 1;
            }

            updateCards(win, tokenId);
            unchecked {
                i++;
            }
        }

        if (g.wager > 0) {
            token.safeTransfer(user, gamesPlayed[gameIndex].wager * 2);
        }
    }

    /**
     * @dev Registers a Discord ID to the calling player's address.
     * Throws an error if the player has already registered a Discord ID.
     * @param _discordId The Discord ID to be registered.
     */
    function registerId(uint64 _discordId) external {
        address player = msg.sender;
        require(playerData[player]._discordId == 0, "Already registered.");
        playerData[player]._discordId = _discordId;
    }

    function updatePfp(address _nft, uint256 _tokenId) external {
        require(IERC721(_nft).ownerOf(_tokenId) == msg.sender, "Not the owner of this item.");
        playerData[msg.sender]._pfpArrayLength++;
        playerPfP[msg.sender].push(Pfp(_nft, _tokenId));
    }

    function getPfp(address _player) external view returns (Pfp[] memory, uint256) {
        Pfp[] memory pfp = new Pfp[](playerData[_player]._pfpArrayLength);
        uint256 count = 0;
        for (uint256 i = 0; i < playerData[_player]._pfpArrayLength; i++) {
            if (IERC721(playerPfP[_player][i]._nft).ownerOf(playerPfP[_player][i]._tokenId) == _player) {
                pfp[count] = playerPfP[_player][i];
                count++;
            }
            unchecked {
                i++;
            }
        }
        return (pfp, count);
    }

    /**
     * @dev Increments the win count for the winner and the loss count for the loser.
     * @param _winner The address of the player who won the game.
     * @param _loser The address of the player who lost the game.
     */
    function _assignScore(address _winner, address _loser) internal {
        playerData[_winner]._wins++;
        playerData[_loser]._losses++;
    }

    // Function to add a unique player
    function _addUniquePlayer(address _player) internal {
        if (!isPlayerAdded[_player]) {
            allPlayers.push(_player);
            isPlayerAdded[_player] = true;
        }
    }

    function getTop10Players() public view returns (address[] memory) {
        uint256 playerCount = allPlayers.length;

        // Create a temporary array for sorting
        address[] memory sortedPlayers = new address[](playerCount);
        for (uint256 i = 0; i < playerCount; i++) {
            sortedPlayers[i] = allPlayers[i];
        }

        // Sort the array
        for (uint256 i = 0; i < playerCount; i++) {
            for (uint256 j = i + 1; j < playerCount; j++) {
                if (playerData[sortedPlayers[i]]._wins < playerData[sortedPlayers[j]]._wins) {
                    // swap
                    address temp = sortedPlayers[i];
                    sortedPlayers[i] = sortedPlayers[j];
                    sortedPlayers[j] = temp;
                }
            }
        }

        // Prepare the top 10 list
        uint256 topCount = playerCount < 10 ? playerCount : 10;
        address[] memory top10Players = new address[](topCount);

        for (uint256 i = 0; i < topCount; i++) {
            top10Players[i] = sortedPlayers[i];
        }

        return top10Players;
    }

    /**
     * @dev function to view deck
     * @param player check players deck
     * @return size the number of cards in deck
     * @return deck the tokenIds of cards in deck
     */
    function deckInfo(address player) external view returns (uint256 size, uint256[] memory deck) {
        size = playersDeck[player].length;
        deck = playersDeck[player];
    }

    /**
     * @dev function to return game Indexes
     * @return game index array
     */
    function gamesNeedPlayer() external view returns (uint256[] memory) {
        return gamesWaitingPlayer;
    }

    /**
     * @dev Fetches the data of a game.
     *
     * @param gameID The ID of the game to fetch.
     *
     * @return board The current game board.
     * @return player1 The first player's address.
     * @return player2 The second player's address.
     * @return player1Hand The first player's hand.
     * @return player2Hand The second player's hand.
     * @return player1Points The first player's points.
     * @return player2Points The second player's points.
     * @return isTurn Indicates whether it's player 1's turn or not.
     * @return gameFinished Indicates whether the game is finished or not.
     * @return wager The wager of the game.
     * @return tradeRule The trading rule being used in the game.
     * @return lastMove The timestamp of the last move.
     */
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
        )
    {
        GamePlay storage game = gamesPlayed[gameID];

        return (
            game.board,
            game.player1,
            game.player2,
            game.playerHand[game.player1],
            game.playerHand[game.player2],
            game.points[game.player1],
            game.points[game.player2],
            game.isTurn,
            game.gameFinished,
            game.wager,
            game.tradeRule,
            game.lastMove
        );
    }

    /**
     * @dev returns gameIndexes that player is current involved in and finished
     * @param player address to check
     * @return gamesIndexes a list of indexes
     */
    function playerGamesPlayed(address player) external view returns (uint256[] memory gamesIndexes) {
        gamesIndexes = playerGames[player];
    }

    /**
     * @dev function to see if game was forfeited by a player
     * @param gameIndex the game in query of
     */
    function forfeit(uint256 gameIndex) public view returns (bool) {
        return (
            gamesPlayed[gameIndex].lastMove != 0
                && gamesPlayed[gameIndex].lastMove + gameIndexToTimerRule[gameIndex] < block.timestamp
                && !gamesPlayed[gameIndex].gameFinished
        );
    }

    /**
     * @dev function to see if game is finalized meaning no more moves left AND winnings are also claimed.
     * @param gameIndex the game in query of
     */
    function finalized(uint256 gameIndex) public view returns (bool) {
        return gamesPlayed[gameIndex].isFinalized;
    }

    /**
     * @dev function to fetch starting hands for players in a specific gameId
     * @param _player is the player we are interested in
     * @param _gameId is the gameId we are interested in
     */
    function getStartingHand(address _player, uint256 _gameId) external view returns (uint256[] memory _startingHand) {
        GamePlay storage gp = gamesPlayed[_gameId];
        return gp.startingHand[_player];
    }

    /**
     * @dev Fetches the deposited cards available for a player.
     * @param _player The address of the player whose available cards we want to fetch.
     * @return _tokenIds An array containing the token IDs of the cards that are available.
     */
    function getDepositedAvailableCards(address _player) external view returns (uint256[] memory _tokenIds) {
        uint256 size = playersDeck[_player].length;
        uint256[] memory result = new uint256[](size);
        uint256 count = 0;

        for (uint256 i = 0; i < size; i++) {
            uint256 tokenId = playersDeck[_player][i];
            if (tokenIdToCard[tokenId].currentGameIndex == 0) {
                result[count] = tokenId;
                count++;
            }
        }

        // Manually copy over to a new array that has the exact size
        _tokenIds = new uint256[](count);
        for (uint256 i = 0; i < count; i++) {
            _tokenIds[i] = result[i];
        }

        return _tokenIds;
    }

    /**
     * @dev Fetches a list of active (non-finalized) game IDs for a given player.
     * @param _player The address of the player.
     */
    function getActivePlayerGames(address _player) external view returns (uint256[] memory _gameIds) {
        uint256[] memory temp = playerGames[_player];
        uint256 count = 0;

        // Initialize the output array with max possible length (same as temp)
        _gameIds = new uint256[](temp.length);

        for (uint256 i = 0; i < temp.length; i++) {
            uint256 gameId = temp[i];
            GamePlay storage game = gamesPlayed[gameId];

            // Condition 1: gameFinished is true and either player is the zero address
            bool condition1 = game.gameFinished && (game.player1 == address(0) || game.player2 == address(0));

            // Condition 2: isFinalized is true
            bool condition2 = game.isFinalized;

            // Skip this game if any of the conditions are met
            if (condition1 || condition2) {
                continue;
            }

            // Otherwise, add it to the results
            if (game.player1 == _player || game.player2 == _player) {
                _gameIds[count] = gameId;
                count++;
            }
        }

        // Create the result array with the exact size
        uint256[] memory result = new uint256[](count);
        for (uint256 i = 0; i < count; i++) {
            result[i] = _gameIds[i];
        }

        return result;
    }
}

library putma {
    function sumFind(uint8[4] memory sum) internal pure returns (uint8[4] memory a, bool truth) {
        if (sum[0] > 0) {
            if (sum[0] == sum[1]) {
                a[0] = 1;
                truth = true;
            }
            if (sum[0] == sum[2]) {
                a[0] = 2;
                truth = true;
            }
            if (sum[0] == sum[3]) {
                a[0] = 3;
                truth = true;
            }
        }
        if (sum[1] > 0) {
            if (sum[1] == sum[2]) {
                a[1] = 2;
                truth = true;
            }
            if (sum[1] == sum[3]) {
                a[1] = 3;
                truth = true;
            }
        }
        if (sum[2] > 0) {
            if (sum[2] == sum[3]) {
                a[2] = 3;
                truth = true;
            }
        }
    }

    function cardsToCollect(uint256 tradeRule, uint8 winnerPoints, uint8 otherPoints) internal pure returns (uint8) {
        if (winnerPoints == otherPoints) {
            return 0;
        }
        if (tradeRule == 0) {
            return 1;
        }
        if (tradeRule == 1) {
            uint8 a = winnerPoints - otherPoints;
            if (a > 5) {
                a = 5;
            }
            return a;
        }
        if (tradeRule == 3) {
            return 5;
        }

        return 0;
    }
}
