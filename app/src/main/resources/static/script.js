let board = ["", "", "", "", "", "", "", "", ""];
let currentPlayer = "X";
let gameOver = false;

function play(index) {
    if (board[index] !== "" || gameOver) return;

    board[index] = currentPlayer;
    document.getElementsByClassName("cell")[index].innerText = currentPlayer;

    if (checkWinner()) {
        document.getElementById("status").innerText =
            currentPlayer + " wins!";
        gameOver = true;
        return;
    }

    if (!board.includes("")) {
        document.getElementById("status").innerText = "Draw!";
        gameOver = true;
        return;
    }

    currentPlayer = currentPlayer === "X" ? "O" : "X";
}

function checkWinner() {
    const wins = [
        [0,1,2],[3,4,5],[6,7,8],
        [0,3,6],[1,4,7],[2,5,8],
        [0,4,8],[2,4,6]
    ];

    return wins.some(combo =>
        combo.every(i => board[i] === currentPlayer)
    );
}

function reset() {
    board = ["", "", "", "", "", "", "", "", ""];
    gameOver = false;
    currentPlayer = "X";
    document.getElementById("status").innerText = "";
    Array.from(document.getElementsByClassName("cell"))
        .forEach(cell => cell.innerText = "");
}
