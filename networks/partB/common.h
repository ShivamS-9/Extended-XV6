#ifndef COMMON_H
#define COMMON_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <sys/time.h>

#define SERVER_IP "127.0.0.1"
#define SERVER_PORT 12345
#define BUFFER_SIZE 1024
#define CHUNK_SIZE 100
#define MAX_CHUNKS 100
#define TIMEOUT_SEC 0.1

typedef struct
{
    uint32_t seq_num;
    uint32_t total_chunks;
    char data[CHUNK_SIZE];
} Packet;

// Function to split the message into chunks (packets)
void split_message(const char *message, Packet *packets, int *total_chunks)
{
    int msg_len = strlen(message);
    *total_chunks = (msg_len + CHUNK_SIZE - 1) / CHUNK_SIZE;

    for (int i = 0; i < *total_chunks; i++)
    {
        packets[i].seq_num = i + 1;
        packets[i].total_chunks = *total_chunks;
        strncpy(packets[i].data, message + i * CHUNK_SIZE, CHUNK_SIZE);
    }
}

// Function to reassemble the message from chunks
void reassemble_message(Packet *packets, int total_chunks, char *message)
{
    for (int i = 0; i < total_chunks; i++)
    {
        memcpy(message + (packets[i].seq_num - 1) * CHUNK_SIZE, packets[i].data, CHUNK_SIZE);
    }
    message[total_chunks * CHUNK_SIZE] = '\0';
}

// Function to send packets with retries
int send_with_retry(int sockfd, Packet *packet, const struct sockaddr *dest_addr, socklen_t addrlen)
{
    int retries = 0;
    uint32_t ack;

    while (retries < 5)
    {
        sendto(sockfd, packet, sizeof(Packet), 0, dest_addr, addrlen);

        fd_set readfds;
        struct timeval tv;
        FD_ZERO(&readfds);
        FD_SET(sockfd, &readfds);
        tv.tv_sec = 0;
        tv.tv_usec = TIMEOUT_SEC * 1000000;

        if (select(sockfd + 1, &readfds, NULL, NULL, &tv) > 0)
        {
            recvfrom(sockfd, &ack, sizeof(ack), 0, NULL, NULL);
            if (ack == packet->seq_num)
            {
                return 0; // Success
            }
        }

        printf("Timeout occurred. Retrying chunk %d...\n", packet->seq_num);
        retries++;
    }

    printf("Max retries reached for chunk %d. Transmission failed.\n", packet->seq_num);
    return -1;
}

#endif // COMMON_H
