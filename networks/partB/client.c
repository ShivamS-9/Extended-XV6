// client.c
#include "common.h"

int main()
{
    int sockfd;
    struct sockaddr_in server_addr;
    socklen_t server_len = sizeof(server_addr);
    Packet packets[MAX_CHUNKS];
    char message[MAX_CHUNKS * CHUNK_SIZE] = {0};

    // Create UDP socket
    if ((sockfd = socket(AF_INET, SOCK_DGRAM, 0)) < 0)
    {
        perror("Socket creation failed");
        exit(EXIT_FAILURE);
    }

    memset(&server_addr, 0, sizeof(server_addr));
    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = inet_addr(SERVER_IP);
    server_addr.sin_port = htons(SERVER_PORT);

    // Get message from user
    char buffer[BUFFER_SIZE];
    printf("Enter a message to send: ");
    fgets(buffer, BUFFER_SIZE, stdin);
    buffer[strcspn(buffer, "\n")] = 0; // Remove newline

    // Split message into packets
    int total_chunks;
    split_message(buffer, packets, &total_chunks);

    // Send packets
    for (int i = 0; i < total_chunks; i++)
    {
        if (send_with_retry(sockfd, &packets[i], (struct sockaddr *)&server_addr, server_len) < 0)
        {
            printf("Failed to send chunk %d\n", i + 1);
        }
    }

    printf("Message sent successfully\n");

    // Receive response
    int received_chunks = 0;
    int total_response_chunks = 0;

    while (received_chunks < MAX_CHUNKS)
    {
        Packet packet;
        ssize_t received = recvfrom(sockfd, &packet, sizeof(Packet), 0, NULL, NULL);

        if (received < 0)
        {
            perror("recvfrom failed");
            continue;
        }

        // Store the chunk
        packets[packet.seq_num - 1] = packet;
        received_chunks++;
        total_response_chunks = packet.total_chunks;

        // Send ACK
        uint32_t ack = packet.seq_num;
        sendto(sockfd, &ack, sizeof(ack), 0, (struct sockaddr *)&server_addr, server_len);

        if (received_chunks == total_response_chunks)
        {
            break;
        }
    }

    // Reassemble and print the response
    reassemble_message(packets, total_response_chunks, message);
    printf("Received response: %s\n", message);

    close(sockfd);
    return 0;
}
