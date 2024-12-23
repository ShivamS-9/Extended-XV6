#ifndef COMMON_H
#define COMMON_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>

#define PORT 8080
#define BOARD_SIZE 3
#define BUFFER_SIZE 1024

// Game states
#define WAITING_FOR_PLAYERS 0
#define GAME_IN_PROGRESS 1
#define GAME_OVER 2

// Player symbols
#define PLAYER_X 'X'
#define PLAYER_O 'O'
#define EMPTY ' '

// Board structure
typedef struct {
    char grid[BOARD_SIZE][BOARD_SIZE];
} Board;

// Function prototypes
void init_board(Board *board);
void print_board(Board *board);
int make_move(Board *board, int row, int col, char symbol);
int check_win(Board *board, char symbol);
int is_board_full(Board *board);

// Initialize the board
void init_board(Board *board) {
    for (int i = 0; i < BOARD_SIZE; i++) {
        for (int j = 0; j < BOARD_SIZE; j++) {
            board->grid[i][j] = EMPTY;
        }
    }
}

// Print the board
void print_board(Board *board) {
    printf("\n");
    for (int i = 0; i < BOARD_SIZE; i++) {
        for (int j = 0; j < BOARD_SIZE; j++) {
            printf(" %c ", board->grid[i][j]);
            if (j < BOARD_SIZE - 1) printf("|");
        }
        printf("\n");
        if (i < BOARD_SIZE - 1) printf("---+---+---\n");
    }
    printf("\n");
}

// Make a move on the board
int make_move(Board *board, int row, int col, char symbol) {
    if (row < 0 || row >= BOARD_SIZE || col < 0 || col >= BOARD_SIZE || board->grid[row][col] != EMPTY) {
        return 0; // Invalid move
    }
    board->grid[row][col] = symbol;
    return 1; // Valid move
}

// Check if a player has won
int check_win(Board *board, char symbol) {
    // Check rows and columns
    for (int i = 0; i < BOARD_SIZE; i++) {
        if ((board->grid[i][0] == symbol && board->grid[i][1] == symbol && board->grid[i][2] == symbol) ||
            (board->grid[0][i] == symbol && board->grid[1][i] == symbol && board->grid[2][i] == symbol)) {
            return 1;
        }
    }
    // Check diagonals
    if ((board->grid[0][0] == symbol && board->grid[1][1] == symbol && board->grid[2][2] == symbol) ||
        (board->grid[0][2] == symbol && board->grid[1][1] == symbol && board->grid[2][0] == symbol)) {
        return 1;
    }
    return 0;
}

// Check if the board is full
int is_board_full(Board *board) {
    for (int i = 0; i < BOARD_SIZE; i++) {
        for (int j = 0; j < BOARD_SIZE; j++) {
            if (board->grid[i][j] == EMPTY) {
                return 0;
            }
        }
    }
    return 1;
}

#endif // COMMON_H