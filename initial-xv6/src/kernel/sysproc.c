#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
  int n;
  argint(0, &n);
  exit(n);
  return 0; // not reached
}

uint64
sys_getpid(void)
{
  return myproc()->pid;
}

uint64
sys_fork(void)
{
  return fork();
}

uint64
sys_wait(void)
{
  uint64 p;
  argaddr(0, &p);
  return wait(p);
}

uint64
sys_sbrk(void)
{
  uint64 addr;
  int n;

  argint(0, &n);
  addr = myproc()->sz;
  if (growproc(n) < 0)
    return -1;
  return addr;
}

uint64
sys_sleep(void)
{
  int n;
  uint ticks0;

  argint(0, &n);
  acquire(&tickslock);
  ticks0 = ticks;
  while (ticks - ticks0 < n)
  {
    if (killed(myproc()))
    {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

uint64
sys_kill(void)
{
  int pid;

  argint(0, &pid);
  return kill(pid);
}

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}

uint64
sys_waitx(void)
{
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
  argaddr(1, &addr1); // user virtual memory
  argaddr(2, &addr2);
  int ret = waitx(addr, &wtime, &rtime);
  struct proc *p = myproc();
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    return -1;
  if (copyout(p->pagetable, addr2, (char *)&rtime, sizeof(int)) < 0)
    return -1;
  return ret;
}

int count_syscalls_from_children(struct proc *p, int syscall_index);

uint64
sys_getSysCount(void)
{
  int mask;
  if (argint(0, &mask) < 0)
    return -1;
  struct proc *p = myproc();
  int count = 0;

  for (int i = 0; i < 31; i++)
  {
    if (mask & (1 << i))
    {                               // Check if the ith syscall is selected
      count += p->syscall_count[i]; // Add counts from the current process
      // Optionally, add counts from child processes if required
      count += count_syscalls_from_children(p, i);
      break;
    }
  }

  return count;
}

int count_syscalls_from_children(struct proc *p, int syscall_index)
{
  int total = 0;
  struct proc *child;
  for (child = proc; child < &proc[NPROC]; child++)
  {
    if (child->parent == p)
    {
      total += child->syscall_count[syscall_index];
      total += count_syscalls_from_children(child, syscall_index); // Recursively check the child's children
    }
  }
  return total;
}
// alarm

uint64 sys_sigalarm(void)
{
  int interval;
  uint64 handler;

  if (argint(0, &interval) < 0 || argaddr(1, &handler) < 0)
    return -1;

  struct proc *p = myproc();
  p->alarm_interval = interval;
  p->ticks = 0;
  p->alarm_on_off = 0;
  p->alarm_handler = handler;
  return 0;
}

uint64 sys_sigreturn(void)
{
  struct proc *p = myproc();
  if (p->alarm_on_off == 0)
    return -1;

  memmove(p->trapframe, p->alarm_trapframe, sizeof(struct trapframe));
  kfree(p->alarm_trapframe);
  p->alarm_trapframe = 0;
  p->alarm_on_off = 0;
  return 0;
}

uint64
sys_settickets(void)
{
  int tickets;

  if (argint(0, &tickets) < 0)
    return -1;

  return settickets(tickets);
}