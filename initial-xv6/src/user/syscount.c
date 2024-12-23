
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

char *syscall_name(int mask);

int main(int argc, char *argv[])
{
    if (argc < 3)
    {
        fprintf(2, "Usage: syscount <mask> command [args]\n");
        exit(0);
    }

    int mask = atoi(argv[1]);

    // Fork and execute the command
    int pid = fork();
    if (pid == 0)
    {
        // fprintf(2, "Executing command: %s\n", argv[2]); // Debug line
        argv[argc] = 0;                                 // Null-terminate the arguments
        exec(argv[2], argv + 2);
        fprintf(2, "exec failed\n");
        exit(0);
    }
    else if (pid > 0)
    {
        // In the parent process, wait for the child
        int status;
        wait(&status); // Wait for the child to exit

        // After the command finishes, call the syscall to get the count
        int count = getSysCount(mask);
        fprintf(1, "PID %d called %s %d times.\n", pid, syscall_name(mask), count);
    }
    else
    {
        fprintf(2, "fork failed\n");
    }

    exit(0);
}
char *syscall_name(int mask)
{
    switch (mask)
    {
    case (1 << 1):
        return "fork";
    case (1 << 2):
        return "exit";
    case (1 << 3):
        return "wait";
    case (1 << 4):
        return "pipe";
    case (1 << 5):
        return "read";
    case (1 << 6):
        return "kill";
    case (1 << 7):
        return "exec";
    case (1 << 8):
        return "fstat";
    case (1 << 9):
        return "chdir";
    case (1 << 10):
        return "dup";
    case (1 << 11):
        return "getpid";
    case (1 << 12):
        return "sbrk";
    case (1 << 13):
        return "sleep";
    case (1 << 14):
        return "uptime";
    case (1 << 15):
        return "open";
    case (1 << 16):
        return "write";
    case (1 << 17):
        return "mknod";
    case (1 << 18):
        return "unlink";
    case (1 << 19):
        return "link";
    case (1 << 20):
        return "mkdir";
    case (1 << 21):
        return "close";
    default:
        return "unknown";
    }
}