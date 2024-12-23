// server.c
#include "common.h"

int main()
{
    int sockfd;
    struct sockaddr_in server_addr, client_addr;
    socklen_t client_len = sizeof(client_addr);
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

    // Bind socket to address
    if (bind(sockfd, (struct sockaddr *)&server_addr, sizeof(server_addr)) < 0)
    {
        perror("Bind failed");
        exit(EXIT_FAILURE);
    }

    printf("Server listening on %s:%d\n", SERVER_IP, SERVER_PORT);

    while (1)
    {
        int received_chunks = 0;
        int total_chunks = 0;

        // Receive message
        while (received_chunks < MAX_CHUNKS)
        {
            Packet packet;
            ssize_t received = recvfrom(sockfd, &packet, sizeof(Packet), 0,
                                        (struct sockaddr *)&client_addr, &client_len);

            if (received < 0)
            {
                perror("recvfrom failed");
                continue;
            }

            // Store the chunk
            packets[packet.seq_num - 1] = packet;
            received_chunks++;
            total_chunks = packet.total_chunks;

            // FOR CHECKING LOSS

            // Randomly skip ACKs to simulate loss (skip every third packet)
            // uint32_t ack = packet.seq_num;
            // if (packet.seq_num % 1 != 0)
            // { // Skip sending every  ACK
            //     sendto(sockfd, &ack, sizeof(ack), 0, (struct sockaddr *)&client_addr, client_len);
            // }
            // else
            // {
            //     printf("Simulating loss of ACK for chunk %d\n", packet.seq_num);
            // }

            // Send
            uint32_t ack = packet.seq_num;
            sendto(sockfd, &ack, sizeof(ack), 0, (struct sockaddr *)&client_addr, client_len);

            if (received_chunks == total_chunks)
            {
                break;
            }
        }

        // Reassemble and print the message
        reassemble_message(packets, total_chunks, message);
        printf("Received message: %s\n", message);

        // Prepare and send response
        const char *response = "Message received successfully!";
        Packet response_packets[MAX_CHUNKS];
        int response_chunks;
        split_message(response, response_packets, &response_chunks);

        for (int i = 0; i < response_chunks; i++)
        {
            send_with_retry(sockfd, &response_packets[i],
                            (struct sockaddr *)&client_addr, client_len);
        }

        printf("Response sent successfully\n");
    }

    close(sockfd);
    return 0;
}
