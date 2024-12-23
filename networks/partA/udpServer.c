#include "commonudp.h"

typedef struct
{
    struct sockaddr_in addr;
    int player_num;
} PlayerInfo;

void send_to_player(int sockfd, const char *message, struct sockaddr_in *addr)
{
    sendto(sockfd, message, strlen(message), 0, (struct sockaddr *)addr, sizeof(*addr));
}

void send_to_both(int sockfd, const char *message, PlayerInfo players[2])
{
    for (int i = 0; i < 2; i++)
    {
        send_to_player(sockfd, message, &players[i].addr);
    }
}

int main()
{
    int sockfd;
    char buffer[BUFFER_SIZE];
    struct sockaddr_in servaddr, cliaddr;
    PlayerInfo players[2] = {0};
    int num_players = 0;
    Board board;
    int current_player = 0;
    int game_state = WAITING_FOR_PLAYERS;

    // Creating socket file descriptor
    if ((sockfd = socket(AF_INET, SOCK_DGRAM, 0)) < 0)
    {
        perror("socket creation failed");
        exit(EXIT_FAILURE);
    }

    memset(&servaddr, 0, sizeof(servaddr));
    memset(&cliaddr, 0, sizeof(cliaddr));

    // Filling server information
    servaddr.sin_family = AF_INET;
    servaddr.sin_addr.s_addr = INADDR_ANY;
    servaddr.sin_port = htons(PORT);

    // Bind the socket with the server address
    if (bind(sockfd, (const struct sockaddr *)&servaddr, sizeof(servaddr)) < 0)
    {
        perror("bind failed");
        exit(EXIT_FAILURE);
    }

    printf("Server is waiting for players to connect...\n");

    while (1)
    {
        game_state = WAITING_FOR_PLAYERS;
        num_players = 0;
        current_player = 0;

        // Wait for two players to connect
        while (num_players < 2)
        {
            int len = sizeof(cliaddr);
            int n = recvfrom(sockfd, (char *)buffer, BUFFER_SIZE, MSG_WAITALL,
                             (struct sockaddr *)&cliaddr, &len);
            buffer[n] = '\0';

            if (strcmp(buffer, "JOIN") == 0)
            {
                players[num_players].addr = cliaddr;
                players[num_players].player_num = num_players + 1;
                sprintf(buffer, "Welcome Player %d\n", num_players + 1);
                send_to_player(sockfd, buffer, &cliaddr);
                num_players++;
            }
        }

        game_state = GAME_IN_PROGRESS;
        init_board(&board);

        printf("Game started. Initial board:\n");
        print_board(&board);

        send_to_both(sockfd, "Game started. You are playing Tic-Tac-Toe!\n", players);

        while (game_state == GAME_IN_PROGRESS)
        {
            // Send turn information to current player
            sprintf(buffer, "Your turn (Player %d). Enter row and column (0-2): ", current_player + 1);
            send_to_player(sockfd, buffer, &players[current_player].addr);

            // Send wait message to other player
            sprintf(buffer, "Waiting for Player %d's move...\n", current_player + 1);
            send_to_player(sockfd, buffer, &players[1 - current_player].addr);

            // Receive move from current player
            int len = sizeof(cliaddr);
            int n = recvfrom(sockfd, (char *)buffer, BUFFER_SIZE, MSG_WAITALL,
                             (struct sockaddr *)&cliaddr, &len);
            buffer[n] = '\0';

            // Parse move
            int row, col;
            sscanf(buffer, "%d %d", &row, &col);

            // Make move
            if (make_move(&board, row, col, current_player == 0 ? PLAYER_X : PLAYER_O))
            {
                printf("Player %d made a move at (%d, %d)\n", current_player + 1, row, col);
                print_board(&board);

                sprintf(buffer, "Player %d made a move at row %d, column %d\n", current_player + 1, row, col);
                send_to_both(sockfd, buffer, players);

                // Check for win
                if (check_win(&board, current_player == 0 ? PLAYER_X : PLAYER_O))
                {
                    sprintf(buffer, "Player %d wins!\n", current_player + 1);
                    game_state = GAME_OVER;
                }
                else if (is_board_full(&board))
                {
                    strcpy(buffer, "It's a draw!\n");
                    game_state = GAME_OVER;
                }
                else
                {
                    current_player = 1 - current_player; // Switch player
                    strcpy(buffer, "Move accepted.\n");
                }
            }
            else
            {
                strcpy(buffer, "Invalid move. Try again.\n");
            }

            // Send game status to both players
            send_to_both(sockfd, buffer, players);
        }

        // Ask players if they want to play again
        send_to_both(sockfd, "Do you want to play again? (yes/no): ", players);

        int play_again[2] = {0, 0};
        for (int i = 0; i < 2; i++)
        {
            int len = sizeof(cliaddr);
            int n = recvfrom(sockfd, (char *)buffer, BUFFER_SIZE, MSG_WAITALL,
                             (struct sockaddr *)&cliaddr, &len);
            buffer[n] = '\0';
            play_again[i] = (strncmp(buffer, "yes", 3) == 0);
        }

        if (play_again[0] && play_again[1])
        {
            send_to_both(sockfd, "Both players agreed to play again. Starting new game...\n", players);
        }
        else if (!play_again[0] && !play_again[1])
        {
            send_to_both(sockfd, "Both players chose not to play again. Ending game...\n", players);
            break;
        }
        else
        {
            for (int i = 0; i < 2; i++)
            {
                if (play_again[i])
                {
                    send_to_player(sockfd, "Your opponent chose not to play again. Ending game...\n", &players[i].addr);
                }
            }
            break;
        }
    }

    close(sockfd);
    return 0;
}