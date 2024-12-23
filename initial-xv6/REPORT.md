
# MP-2 Part A Report

## 1. System Calls
### A. Gotta count ‘em all 

In this task, I implemented a system call `getSysCount` that counts how many times a specific system call is invoked by a process and its children. The user interacts with this feature through the `syscount` user program, which takes a mask to specify the syscall to track.

### Key Modifications:
- **syscall.c:** I added logic to maintain a count for each system call made by processes. For this, I modified the `syscall` function to increment the counter of the specific syscall being tracked.
  
- **proc.h:** In the `proc` structure, I added an array `syscall_count[31]` to keep track of system call counts, with one entry per possible syscall (as we are limited to 31 syscalls).
  
- **sysproc.c:** The new `getSysCount` system call retrieves the count of the specific syscall (using the mask to identify which syscall), and this is returned to the user program.

### syscount program:
- The program parses the mask to identify the syscall number, launches the specified command, and counts the number of times the syscall is invoked until the command exits. 
- Example: 
  ```
  $ syscount 32768 grep hello README.md
  PID 6 called open 1 times.
  ```

---

### B. Timer Alerts: sigalarm and sigreturn 

For this task, I implemented a feature that allows processes to handle timed interrupts, similar to user-level signal handling. The new system calls `sigalarm(interval, handler)` and `sigreturn()` allow a process to be interrupted periodically and execute a custom function.

### Key Modifications:
- **proc.h:** I added two new fields to the `proc` structure: `alarm_interval` to store the number of ticks between each alarm, and `alarm_handler` to store the function pointer to the user-defined handler.
  
- **trap.c:** In the timer interrupt handler, I check if the current process has set an alarm using `sigalarm`. If the process’s CPU ticks exceed the alarm interval, the handler is invoked.
  
- **sigreturn():** This system call restores the process’s execution context after the handler has finished, resuming normal execution where it was interrupted.

---
## 2. Scheduling
### A. Lottery-Based  

For the lottery-based scheduler, I implemented a scheduling policy that assigns each process a number of tickets. The probability of a process running in a given time slice is proportional to the number of tickets it holds.

### Key Modifications:
- **proc.h:** I added a `tickets` field to the `proc` structure to store how many tickets each process holds. I initialized this value to 1 for every new process.
  
- **settickets(int number):** This system call allows a process to change its ticket count. I modified the `proc.c` code to ensure that child processes inherit their parent’s ticket count.

- **scheduler():** I modified the `scheduler()` function to:
  - Randomly select a process to run based on the ticket distribution.
  - Use a pseudo-random number generator to pick a winning ticket.
  - If two processes have the same number of tickets, the one that arrived earlier is chosen to run.
  - Processes with more tickets get a higher chance to run, but in cases where multiple processes have the same number of tickets, the process with the earlier arrival time is given priority.
  
  **Example:**
  - Process A has 3 tickets and arrives at time 0s.
  - Process C has 3 tickets and arrives at time 4s.
  - Even if C wins the lottery, the system will prioritize A because it arrived earlier.

---

### B. MLFQ

For the MLFQ scheduler, I implemented a preemptive scheduling policy that dynamically adjusts the priority of processes based on their CPU usage, aiming to give interactive processes higher priority.

### Key Modifications:
- **proc.h:** I added a `priority_level` field to the `proc` structure to store the current priority queue of each process.
  
- **scheduler():** The scheduler maintains four priority queues (0 being the highest priority, and 3 the lowest). A process starts in queue 0, and depending on its CPU usage, it is moved to lower priority queues.
  - A process is demoted to the next queue if it uses its entire time slice. 
  - I also implemented a priority boost that moves all processes back to queue 0 after 48 ticks to prevent starvation.
  
- **Preemption Logic:** If a higher-priority process becomes ready, it preempts the current process. The scheduler always selects processes from the highest-priority non-empty queue.

### Time Slices:
- Queue 0: 1 tick
- Queue 1: 4 ticks
- Queue 2: 8 ticks
- Queue 3: 16 ticks

---

## 3. Performance and Comparisons

### Performance Comparison:
- I used the `schedulertest` program to compare the performance of the default round-robin scheduler, the lottery-based scheduler, and the MLFQ scheduler.
- The comparison was made by measuring the average waiting and running times of processes under each policy, while forcing all processes to run on a single CPU.
## Performance Comparison

I conducted performance tests using the `schedulertest` command to evaluate the average waiting and running times for processes under different scheduling policies. The tests were performed on a single CPU to ensure consistent results.


| Scheduling Policy      | Run  | Average Waiting Time (ms) | Average Running Time (ms) |
|------------------------|------|---------------------------|----------------------------|
| Default Round Robin    | 1    | 188                       | 12                         |
|                        | 2    | 149                       | 13                         |
| Multi-Level Feedback    | 1    | 158                       | 7                          |
|                        | 2    | 603                       | 16                         |
| Lottery-Based          | 1    | 206                       | 6                          |
|                        | 2    | 520                       | 12                         |

### Analysis:
- The default round-robin scheduler had relatively high average waiting times compared to the other two policies.
- The MLFQ scheduler showed the best average running time in the first run, indicating its efficiency in managing CPU usage.
- The lottery-based scheduler also demonstrated low running times, showcasing its effectiveness in prioritizing processes based on ticket counts.
- Overall, the performance varied between runs, suggesting the influence of process timing and CPU availability on scheduling outcomes.

  
### What is the implication of adding the arrival time in the lottery based scheduling policy? Are there any pitfalls to watch out for? What happens if all processes have the same number of tickets?
- **Implication:** Adding arrival time as a tiebreaker in lottery scheduling ensures that processes arriving earlier have a slight advantage when ticket numbers are equal. This prevents the system from unfairly delaying earlier processes with the same number of tickets.
  
- **Pitfalls:** One potential issue is if new processes with high ticket counts constantly arrive, older processes with fewer tickets may experience starvation.
  
- **Same Number of Tickets:** If all processes have the same number of tickets, the scheduler falls back to a first-come-first-served policy, where earlier processes run first.

### MLFQ Analysis:
- I generated a timeline graph showing which queue a process resides in over time. The x-axis represents elapsed time, and the y-axis represents the queue number. Processes are color-coded to show movement between queues, with a clear indication of the priority boost that moves all processes back to queue 0 after 48 ticks.
