#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

void alarm_handler()
{
    printf("Alarm!\n");
    sigreturn();
}

int main()
{
    sigalarm(10, alarm_handler);

    for (int i = 0; i < 25; i++)
    {
        printf("Tick %d\n", i);
        sleep(1);
    }

    sigalarm(0, 0); // Turn off the alarm
    printf("Done\n");
    exit(0);
}