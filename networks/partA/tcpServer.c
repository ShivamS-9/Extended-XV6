#include "commontcp.h"

void send_to_both(int client_sockets[2], const char *message) {
    send(client_sockets[0], message, strlen(message), 0);
    send(client_sockets[1], message, strlen(message), 0);
}

int main() {
    int server_fd, client_sockets[2];
    struct sockaddr_in address;
    int opt = 1;
    int addrlen = sizeof(address);
    Board board;
    int current_player = 0;
    int game_state = WAITING_FOR_PLAYERS;
    char buffer[BUFFER_SIZE] = {0};

    // Create socket file descriptor
    if ((server_fd = socket(AF_INET, SOCK_STREAM, 0)) == 0) {
        perror("socket failed");
        exit(EXIT_FAILURE);
    }

    // Set socket options
    if (setsockopt(server_fd, SOL_SOCKET, SO_REUSEADDR | SO_REUSEPORT, &opt, sizeof(opt))) {
        perror("setsockopt");
        exit(EXIT_FAILURE);
    }

    address.sin_family = AF_INET;
    address.sin_addr.s_addr = INADDR_ANY;
    address.sin_port = htons(PORT);

    // Bind the socket to the network address and port
    if (bind(server_fd, (struct sockaddr *)&address, sizeof(address)) < 0) {
        perror("bind failed");
        exit(EXIT_FAILURE);
    }

    // Listen for incoming connections
    if (listen(server_fd, 2) < 0) {
        perror("listen");
        exit(EXIT_FAILURE);
    }

    printf("Server is waiting for players to connect...\n");

    // Accept connections from two players
    for (int i = 0; i < 2; i++) {
        if ((client_sockets[i] = accept(server_fd, (struct sockaddr *)&address, (socklen_t*)&addrlen)) < 0) {
            perror("accept");
            exit(EXIT_FAILURE);
        }
        printf("Player %d connected\n", i + 1);
    }

    while (1) {
        game_state = GAME_IN_PROGRESS;
        init_board(&board);

        printf("Game started. Initial board:\n");
        print_board(&board);

        send_to_both(client_sockets, "Game started. You are playing Tic-Tac-Toe!\n");

        while (game_state == GAME_IN_PROGRESS) {
            // Send turn information to current player
            sprintf(buffer, "Your turn (Player %d). Enter row and column (0-2): ", current_player + 1);
            send(client_sockets[current_player], buffer, strlen(buffer), 0);

            // Send wait message to other player
            sprintf(buffer, "Waiting for Player %d's move...\n", current_player + 1);
            send(client_sockets[1 - current_player], buffer, strlen(buffer), 0);

            // Receive move from current player
            int bytes_received = recv(client_sockets[current_player], buffer, BUFFER_SIZE, 0);
            if (bytes_received <= 0) {
                printf("Player %d disconnected\n", current_player + 1);
                game_state = GAME_OVER;
                break;
            }

            // Parse move
            int row, col;
            sscanf(buffer, "%d %d", &row, &col);

            // Make move
            if (make_move(&board, row, col, current_player == 0 ? PLAYER_X : PLAYER_O)) {
                printf("Player %d made a move at (%d, %d)\n", current_player + 1, row, col);
                print_board(&board);

                sprintf(buffer, "Player %d made a move at row %d, column %d\n", current_player + 1, row, col);
                send_to_both(client_sockets, buffer);

                // Check for win
                if (check_win(&board, current_player == 0 ? PLAYER_X : PLAYER_O)) {
                    sprintf(buffer, "Player %d wins!\n", current_player + 1);
                    game_state = GAME_OVER;
                } else if (is_board_full(&board)) {
                    strcpy(buffer, "It's a draw!\n");
                    game_state = GAME_OVER;
                } else {
                    current_player = 1 - current_player; // Switch player
                    strcpy(buffer, "Move accepted.\n");
                }
            } else {
                strcpy(buffer, "Invalid move. Try again.\n");
            }

            // Send game status to both players
            send_to_both(client_sockets, buffer);
        }

        // Ask players if they want to play again
        send_to_both(client_sockets, "Do you want to play again? (yes/no): ");

        int play_again[2] = {0, 0};
        for (int i = 0; i < 2; i++) {
            memset(buffer, 0, BUFFER_SIZE);
            recv(client_sockets[i], buffer, BUFFER_SIZE, 0);
            play_again[i] = (strncmp(buffer, "yes", 3) == 0);
        }

        if (play_again[0] && play_again[1]) {
            send_to_both(client_sockets, "Both players agreed to play again. Starting new game...\n");
            current_player = 0; // Reset to player 1
        } else if (!play_again[0] && !play_again[1]) {
            send_to_both(client_sockets, "Both players chose not to play again. Ending game...\n");
            break;
        } else {
            for (int i = 0; i < 2; i++) {
                if (play_again[i]) {
                    send(client_sockets[i], "Your opponent chose not to play again. Ending game...\n", 55, 0);
                }
            }
            break;
        }
    }

    // Close the connections
    close(client_sockets[0]);
    close(client_sockets[1]);
    close(server_fd);

    return 0;
}