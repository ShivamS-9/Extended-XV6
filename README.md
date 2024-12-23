# XV6 Operating System Enhancement Project

## Overview

This project enhances the XV6 operating system with new system calls, advanced scheduling algorithms, and networking functionalities. The main focus is to integrate real-world operating system concepts like process scheduling and networking into the XV6 OS. The enhancements made in this project aim to improve process management, facilitate networking, and provide more control over system behavior. The project demonstrates practical implementations of key operating system concepts, including process scheduling with Lottery-based Scheduling (LBS) and Multi-Level Feedback Queue (MLFQ), as well as reliable networking functionalities using TCP and UDP.


## Table of Contents
1. [Introduction](#introduction)
2. [Project Structure](#project-structure)
3. [System Calls](#system-calls)
   - [getSysCount](#getsyscount)
   - [sigalarm and sigreturn](#sigalarm-and-sigreturn)
4. [Scheduling](#scheduling)
   - [Lottery Based Scheduling (LBS)](#lottery-based-scheduling-lbs)
   - [Multi-Level Feedback Queue (MLFQ)](#multi-level-feedback-queue-mlfq)
5. [Networking](#networking)
   - [Multiplayer Tic-Tac-Toe](#multiplayer-tic-tac-toe)
   - [TCP Functionality using UDP](#tcp-functionality-using-udp)
6. [Building and Running](#building-and-running)
7. [Testing](#testing)
8. [Performance Analysis](#performance-analysis)

## System Calls

### getSysCount

`getSysCount` counts the number of times a specific system call was called by a process.

#### Implementation:
- Added `sys_getsyscount()` in `kernel/sysproc.c`.
- Modified `kernel/syscall.c` to track system call counts.
- Created `user/syscount.c` for the user program.

#### Usage:
```
$ syscount <mask> command [args]
```

Example:
```
$ syscount 32768 grep hello README.md
PID 6 called open 1 times.
```

### sigalarm and sigreturn

`sigalarm` sets up a timer to call a handler function after a specified interval of CPU time. `sigreturn` resets the process state after the handler is called.

#### Implementation:
- Added `sys_sigalarm()` and `sys_sigreturn()` in `kernel/sysproc.c`.
- Modified `kernel/proc.h` to add fields for alarm tracking.
- Updated timer interrupt handler in `kernel/trap.c`.

#### Usage:
See `user/alarmtest.c` for example usage.

## Scheduling

### Lottery Based Scheduling (LBS)

A preemptive scheduler that assigns CPU time proportional to the number of tickets a process holds.

#### Implementation:
- Modified `kernel/proc.c` to implement the lottery algorithm in `scheduler()`.
- Added `sys_settickets()` system call for setting process tickets.
- Updated `struct proc` in `kernel/proc.h` to include ticket count and arrival time.

### Multi-Level Feedback Queue (MLFQ)

A preemptive scheduler with multiple priority queues and dynamic priority adjustment.

#### Implementation:
- Created four priority queues in `kernel/proc.c`.
- Modified `scheduler()` in `kernel/proc.c` to implement MLFQ logic.
- Implemented priority boosting mechanism.
- Updated `struct proc` to include priority level and time slice information.

## Networking

### XOXO

A client-server implementation of Tic-Tac-Toe using both TCP and UDP.

#### Implementation:
- TCP Server: `networks/partA/tcpServer.c`
- TCP Client: `networks/partA/tcpClient.c`
- Common code: `networks/partA/commontcp.c`
- UDP Server: `networks/partA/udpServer.c`
- UDP Client: `networks/partA/udpClient.c`
- Common code: `networks/partA/commonudp.c`
- Implements game logic, turn management, and win/draw detection.

#### Usage:
1. Compile: `gcc tcpserver.c -o tcpS` and `gcc tcplient.c -o tcpC`
2. Run server: `./tcpS`
3. Run two instances of client: `./tcpC`

Similar usage for UDP

### Fake it till you make it

Implements reliable data transfer features of TCP over UDP.

#### Implementation:
- Sender: `networks/partB/server.c`
- Receiver: `networks/partB/client.c`
- Implements data sequencing, acknowledgments, and retransmissions.

#### Usage:
1. Compile: `gcc -o sender server.c` and `gcc -o receiver client.c`
2. Run receiver: `./receiver`
3. Run sender: `./sender <message>`

## Building and Running

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/xv6-enhanced.git
   cd xv6-enhanced
   ```

2. Build XV6 with a specific scheduler:
   ```
   make clean
   make qemu SCHEDULER=LBS  # For Lottery Based Scheduling
   make qemu SCHEDULER=MLFQ  # For Multi-Level Feedback Queue
   ```

   For default round-robin scheduling:
   ```
   make clean
   make qemu
   ```

3. Run specific tests or programs within QEMU.

## Testing

- System Calls: Use `syscount` and `alarmtest` programs.
- Scheduling: Use `schedulertest` program to compare scheduler performance.
- Networking: Follow usage instructions in the Networking section.

## Performance Analysis

This also contains a report on performance analysis between different types of scheduling processes.
