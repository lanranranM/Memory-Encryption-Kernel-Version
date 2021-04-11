#include "types.h"
#include "x86.h"
#include "defs.h"
#include "date.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
  return fork();
}

int
sys_exit(void)
{
  exit();
  return 0;  // not reached
}

int
sys_wait(void)
{
  return wait();
}

int
sys_kill(void)
{
  int pid;

  if(argint(0, &pid) < 0)
    return -1;
  return kill(pid);
}

int
sys_getpid(void)
{
  return myproc()->pid;
}

int
sys_sbrk(void)
{
  int addr;
  int n;

  if(argint(0, &n) < 0)
    return -1;
  addr = myproc()->sz;
  if(growproc(n) < 0)
    return -1;
  return addr;
}

int
sys_sleep(void)
{
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}

//changed: added wrapper here
int sys_mencrypt(void) {
  int len;
  char * virtual_addr;

  //TODO: what to do if len is 0?

  //dummy size because we're dealing with actual pages here
  if(argint(1, &len) < 0)
    return -1;
  if (len == 0) {
    return 0;
  }
  if (len < 0) {
    return -1;
  }
  if (argptr(0, &virtual_addr, 1) < 0) {
    return -1;
  }

  //geq or ge?
  if ((void *) virtual_addr >= (void *)KERNBASE) {
    return -1;
  }
  //virtual_addr = (char *)5000;
  return mencrypt((char*)virtual_addr, len);
}

//changed: added wrapper here
int sys_getpgtable(void) {
  struct pt_entry * entries; 
  int num;

  if(argint(1, &num) < 0)

    return -1;


  if(argptr(0, (char**)&entries, num*sizeof(struct pt_entry)) < 0){
    return -1;
  }
  return getpgtable(entries, num);
}

//changed: added wrapper here
int sys_dump_rawphymem(void) {
  uint physical_addr; 
  char * buffer;

  if(argptr(1, &buffer, PGSIZE) < 0)
    return -1;

  //dummy size because we're dealing with actual pages here
  if(argint(0, (int*)&physical_addr) < 0)
    return -1;

  return dump_rawphymem(physical_addr, buffer);
}