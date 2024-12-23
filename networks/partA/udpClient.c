#include "commonudp.h"

int main()
{
    int sockfd;
    char buffer[BUFFER_SIZE];
    struct sockaddr_in servaddr;

    // Creating socket file descriptor
    if ((sockfd = socket(AF_INET, SOCK_DGRAM, 0)) < 0)
    {
        perror("socket creation failed");
        exit(EXIT_FAILURE);
    }

    memset(&servaddr, 0, sizeof(servaddr));

    // Filling server information
    servaddr.sin_family = AF_INET;
    servaddr.sin_port = htons(PORT);
    servaddr.sin_addr.s_addr = INADDR_ANY;

    int n;
    unsigned int len;

    // Send JOIN message to server
    sendto(sockfd, "JOIN", strlen("JOIN"), 0, (struct sockaddr *)&servaddr, sizeof(servaddr));

    printf("Sent JOIN request to server. Waiting for game to start...\n");

    while (1)
    {
        n = recvfrom(sockfd, (char *)buffer, BUFFER_SIZE, MSG_WAITALL,
                     (struct sockaddr *)&servaddr, &len);
        buffer[n] = '\0';
        printf("%s", buffer);

        // If it's this player's turn, make a move
        if (strstr(buffer, "Your turn"))
        {
            fgets(buffer, BUFFER_SIZE, stdin);
            sendto(sockfd, buffer, strlen(buffer), 0, (struct sockaddr *)&servaddr, sizeof(servaddr));
        }

        // Check if the game is over and the server is asking to play again
        if (strstr(buffer, "Do you want to play again?"))
        {
            fgets(buffer, BUFFER_SIZE, stdin);
            sendto(sockfd, buffer, strlen(buffer), 0, (struct sockaddr *)&servaddr, sizeof(servaddr));

            // Receive server's response about playing again
            n = recvfrom(sockfd, (char *)buffer, BUFFER_SIZE, MSG_WAITALL,
                         (struct sockaddr *)&servaddr, &len);
            buffer[n] = '\0';
            printf("%s", buffer);

            // If the game is not continuing, break the loop
            if (strstr(buffer, "Ending game"))
            {
                break;
            }
        }
    }

    close(sockfd);
    return 0;
}