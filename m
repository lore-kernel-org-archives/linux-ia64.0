From: Philippe Couvee <PHILIPPE.COUVEE@BULL.NET>
Date: Fri, 17 Jan 2003 13:48:13 +0000
Subject: [Linux-ia64] LTT on IA64
Message-Id: <marc-linux-ia64-105590709805711@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

hello all, 

I am a new-comer on Linux & IA64, and in order to learn all this technology, I
have started to port the Linux Trace Toolit V0.9.5a (see
http://www.opersys.com/LTT/index.html). So far, I have all the userland tools
and most of the kernel code running. This tool records system events and
produces trace files like : 
  

Trace start time: (1042450308, 79287) 
Trace end time: (1042450310, 79020) 
Trace duration: (1, 999733) 

Number of occurences of: 
        Events: 22647 
        Scheduling changes: 176 
        Kernel timer tics: 4083 
        System call entries: 0 
        System call exits: 0 
        Trap entries: 0 
        Trap exits: 0 
        IRQ entries: 4168 
        IRQ exits: 4168 
        Bottom halves: 0 
        Timer expiries: 3 
        Page allocations: 249 
        Page frees: 32 
        Packets Out: 38 
        Packets In: 40 
  

Tracing CPU 1 only 

#################################################################### 
CPU-ID  Event         Time                    PID     Length  Description 
#################################################################### 
... 

1    IRQ entry       1,042,450,309,106,081    0       10    IRQ : 239, IN-KERNEL 
1    Soft IRQ        1,042,450,309,106,087    0       16    SOFT IRQ : 0 
1    Soft IRQ        1,042,450,309,106,089    0       16    TASKLET HI ACTION :
0x04A57230 
1    Kernel timer    1,042,450,309,106,090    0       8 
1    IRQ exit        1,042,450,309,106,091    0       8 
1    Sched change    1,042,450,309,106,115    1273    32    IN : 1273; OUT : 0;
STATE : 0 
1    File system     1,042,450,309,106,120    1273    32    SELECT : 0; TIMEOUT
: 4294967295 
1    File system     1,042,450,309,106,125    1273    32    SELECT : 3; TIMEOUT
: 4294967295 
1    File system     1,042,450,309,106,132    1273    32    READ : 3; COUNT :
1025 
1    File system     1,042,450,309,106,206    1273    32    WRITE : 0; COUNT :
965 
1    Network         1,042,450,309,106,221    1273    16    PACKET OUT; PROTOCOL
: 8 
1    File system     1,042,450,309,106,232    1273    32    SELECT : 0; TIMEOUT
: 4294967295 
1    Memory          1,042,450,309,106,235    1273    24    PAGE ALLOC ORDER : 0 
1    File system     1,042,450,309,106,237    1273    32    SELECT : 3; TIMEOUT
: 4294967295 
1    Sched change    1,042,450,309,106,242    0       32    IN : 0; OUT : 1273;
STATE : 1 
1    IRQ entry       1,042,450,309,106,248    0       10    IRQ : 55, IN-KERNEL 
1    Soft IRQ        1,042,450,309,106,253    0       16    SOFT IRQ : 1 
1    IRQ exit        1,042,450,309,106,256    0       8 
1    IRQ entry       1,042,450,309,107,057    0       10    IRQ : 239, IN-KERNEL 
1    Soft IRQ        1,042,450,309,107,063    0       16    SOFT IRQ : 0 
1    Soft IRQ        1,042,450,309,107,065    0       16    TASKLET HI ACTION :
0x04A57230 
1    Kernel timer    1,042,450,309,107,066    0       8 
1    IRQ exit        1,042,450,309,107,068    0       8 
1    IRQ entry       1,042,450,309,107,321    0       10    IRQ : 55, IN-KERNEL 
1    Soft IRQ        1,042,450,309,107,332    0       16    SOFT IRQ : 2 
1    Network         1,042,450,309,107,336    0       16    PACKET IN; PROTOCOL
: 8 
1    IRQ exit        1,042,450,309,107,346    0       8 
1    Sched change    1,042,450,309,107,544    1273    32   IN : 1273; OUT : 0;
STATE : 0 
1    File system     1,042,450,309,107,548    1273    32   SELECT : 0; TIMEOUT :
4294967295 
1    File system     1,042,450,309,107,551    1273    32   SELECT : 3; TIMEOUT :
4294967295 
1    File system     1,042,450,309,107,558    1273    32   READ : 3; COUNT :
1025 
1    File system     1,042,450,309,107,567    1273    32   WRITE : 0; COUNT : 41 
1    Network         1,042,450,309,107,579    1273    16   PACKET OUT; PROTOCOL
: 8 
1    File system     1,042,450,309,107,590    1273    32   SELECT : 0; TIMEOUT :
4294967295 
1    Memory          1,042,450,309,107,593    1273    24   PAGE ALLOC ORDER : 0 
1    File system     1,042,450,309,107,596    1273    32   SELECT : 3; TIMEOUT :
4294967295 
1    Sched change    1,042,450,309,107,600    0       32   IN : 0; OUT : 1273;
STATE : 1 
1    IRQ entry       1,042,450,309,107,855    0       10   IRQ : 55, IN-KERNEL 
1    Soft IRQ        1,042,450,309,107,865    0       16   SOFT IRQ : 2 
1    Network         1,042,450,309,107,867    0       16   PACKET IN; PROTOCOL :
8 
1    IRQ exit        1,042,450,309,107,876    0       8 
...   

The system events recorded are : 
  

#define TRACE_SYSCALL_ENTRY   1    /* Entry in a given system call */ 
#define TRACE_SYSCALL_EXIT    2    /* Exit from a given system call */ 
#define TRACE_TRAP_ENTRY      3    /* Entry in a trap */ 
#define TRACE_TRAP_EXIT       4    /* Exit from a trap */ 
#define TRACE_IRQ_ENTRY       5    /* Entry in an irq */ 
#define TRACE_IRQ_EXIT        6    /* Exit from an irq */ 
#define TRACE_SCHEDCHANGE     7    /* Scheduling change */ 
#define TRACE_SOFT_IRQ_BOTTOM_HALF        1  /* Conventional bottom-half */ 
#define TRACE_SOFT_IRQ_SOFT_IRQ           2  /* Real soft-irq */ 
#define TRACE_SOFT_IRQ_TASKLET_ACTION     3  /* Tasklet action */ 
#define TRACE_SOFT_IRQ_TASKLET_HI_ACTION  4  /* Tasklet hi-action */ 
#define TRACE_PROCESS_KTHREAD     1  /* Creation of a kernel thread */ 
#define TRACE_PROCESS_FORK        2  /* A fork or clone occured */ 
#define TRACE_PROCESS_EXIT        3  /* An exit occured */ 
#define TRACE_PROCESS_WAIT        4  /* A wait occured */ 
#define TRACE_PROCESS_SIGNAL      5  /* A signal has been sent */ 
#define TRACE_PROCESS_WAKEUP      6  /* Wake up a process */ 
#define TRACE_FILE_SYSTEM_BUF_WAIT_START  1  /* Starting to wait for a data
buffer */ 
#define TRACE_FILE_SYSTEM_BUF_WAIT_END    2  /* End to wait for a data buffer */ 
#define TRACE_FILE_SYSTEM_EXEC            3  /* An exec occured */ 
#define TRACE_FILE_SYSTEM_OPEN            4  /* An open occured */ 
#define TRACE_FILE_SYSTEM_CLOSE           5  /* A close occured */ 
#define TRACE_FILE_SYSTEM_READ            6  /* A read occured */ 
#define TRACE_FILE_SYSTEM_WRITE           7  /* A write occured */ 
#define TRACE_FILE_SYSTEM_SEEK            8  /* A seek occured */ 
#define TRACE_FILE_SYSTEM_IOCTL           9  /* An ioctl occured */ 
#define TRACE_FILE_SYSTEM_SELECT         10  /* A select occured */ 
#define TRACE_FILE_SYSTEM_POLL           11  /* A poll occured */ 
#define TRACE_TIMER_EXPIRED      1  /* Timer expired */ 
#define TRACE_TIMER_SETITIMER    2  /* Setting itimer occurred */ 
#define TRACE_TIMER_SETTIMEOUT   3  /* Setting sched timeout occurred */ 
#define TRACE_MEMORY_PAGE_ALLOC        1  /* Allocating pages */ 
#define TRACE_MEMORY_PAGE_FREE         2  /* Freing pages */ 
#define TRACE_MEMORY_SWAP_IN           3  /* Swaping pages in */ 
#define TRACE_MEMORY_SWAP_OUT          4  /* Swaping pages out */ 
#define TRACE_MEMORY_PAGE_WAIT_START   5  /* Start to wait for page */ 
#define TRACE_MEMORY_PAGE_WAIT_END     6  /* End to wait for page */ 
#define TRACE_SOCKET_CALL     1  /* A socket call occured */ 
#define TRACE_SOCKET_CREATE   2  /* A socket has been created */ 
#define TRACE_SOCKET_SEND     3  /* Data was sent to a socket */ 
#define TRACE_SOCKET_RECEIVE  4  /* Data was read from a socket */ 
#define TRACE_IPC_CALL            1  /* A System V IPC call occured */ 
#define TRACE_IPC_MSG_CREATE      2  /* A message queue has been created */ 
#define TRACE_IPC_SEM_CREATE      3  /* A semaphore was created */ 
#define TRACE_IPC_SHM_CREATE      4  /* A shared memory segment has been created
*/ 
#define TRACE_NETWORK_PACKET_IN   1  /* A packet came in */ 
#define TRACE_NETWORK_PACKET_OUT  2  /* A packet was sent */ 
  

I have included most of these trace points in the kernel code (2.5.45). However,
I need help to implement the tracing of syscall and traps... basically, I have
to call a C function which will record the syscall number and the user address
from which is issued the call : 

/* LTT trace function for syscall entry (in arch/ia64/kernel/traps.c) */ 
asmlinkage void 
ltt_trace_syscall (unsigned long stack) 
{ 
        struct pt_regs *regs = (struct pt_regs *) &stack; 
        trace_syscall_entry sys_entry; 

        sys_entry.syscall_id = (uint8_t)regs->r15; 
        sys_entry.address = (uint64_t) ????; 

        trace_event(TRACE_EV_SYSCALL_ENTRY, &sys_entry); 
} 

The call to this C function has to be inserted somewhere in the common path of
all syscalls : 

in ivt.S ? : 

///////////////////////////////////////////////////////////////////////////////////////// 
// 0x2c00 Entry 11 (size 64 bundles) Break instruction (33) 
ENTRY(break_fault) 
... 
#ifdef CONFIG_TRACE 
    <save scratch regs> 
    <prepare out0> 
    br.call.sptk.many rp=ltt_trace_syscall  // trace syscall 
    <restore scratch regs> 
#endif //CONFIG_TRACE 
  

All my tries so far have led to system hangs... I don't know neither how to save
and restore scratch regs in the assembly part, nor how to find the user address.

Thanks in advance for any help. 
-- 
Philippe Couvee                    HYADES Project
mailto:philippe.couvee@bull.net    LINUX R&D
http://www.bull.com                BULL S.A.  
Phone : +33 4 7629 7170            1, rue de Provence. BP208
Fax : +33 4 7629 7891              F38432 Echirolles CEDEX
Office : B1/383                    FRANCE

