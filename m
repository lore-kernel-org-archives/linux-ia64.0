From: JinShan Xiong <jinshan.xiong@gmail.com>
Date: Mon, 31 Jan 2005 03:56:43 +0000
Subject: How to intercept system calls on ia64 linux kernel
Message-Id: <b3b26beb050130195674d2930c@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi all,

The program has been tested on a HP-ia machine with redhat AS2.1
installed, and the kernel version is 2.4.18-e.47smp.

Thanks helps from David .

JinShan

Here is the source code:
/* ro.c */
/* vi: set ts=4 sw=4 expandtab: */

#include <linux/config.h>
#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/unistd.h>
#include <linux/sched.h>
#include <asm/pgtable.h>
#include <linux/vmalloc.h>
#include <linux/mm.h>
#include <asm/uaccess.h>

extern unsigned long sys_call_table[];

//static long (*old_time)(struct timeval *, struct timezone *);
//extern unsigned long new_time_stub;
static unsigned long old_time;
extern void new_time_stub();
struct foo {
    void *ip;
    void *gp;
};

asm (
"       .text\n"
"        .proc new_time_stub\n"
"new_time_stub:"    
"       .prologue\n"
"       .regstk 2, 3, 2, 0\n"
"       .save ar.pfs, loc1\n"
"       alloc loc1 = ar.pfs, 2, 3, 2, 0\n"
"       movl r2 = @gprel(zero);;\n"
"       .save rp, loc0\n"
"       mov loc0 = rp\n"
"       mov loc2 = gp\n"
"       sub gp = r0, r2\n"
"       mov out0 = in0\n"
"       mov out1 = in1\n"
"       br.call.sptk.many rp = new_time\n"
"1:      mov rp = loc0\n"
"       mov ar.pfs = loc1\n"
"       mov gp = loc2\n"
"       br.ret.sptk.many rp\n"
"       .endp\n"
);

static atomic_t time_enter_count = ATOMIC_INIT(0);
long new_time(struct timeval *tv, struct timezone *tz)
{
    int ret = -EFAULT;
    atomic_inc(&time_enter_count);
    printk("time be called!\n");
    if (tv) {
        struct timeval ktv;
        do_gettimeofday(&ktv);
        if (copy_to_user(tv, &ktv, sizeof(ktv))) {
            goto out;
        }
    }
    if (tz) {
        extern struct timezone sys_tz;
        if (copy_to_user(tz, &sys_tz, sizeof(sys_tz))) {
            goto out;
        }
    }
    ret = 0;

out:
    atomic_dec(&time_enter_count);
    return ret;
}

int init_module(void)
{
    printk("new_time_stub is %llx\n", new_time_stub);
    old_time = sys_call_table[__NR_gettimeofday - 1024];
    sys_call_table[__NR_gettimeofday - 1024] = ((struct
foo*)&new_time_stub)->ip;
    printk("old_time is %llx\n", old_time);
    return 0;
}

void cleanup_module()
{
    /* should restore syscall here! */
    sys_call_table[__NR_gettimeofday - 1024] = old_time; 
    printk("Byebye!\n");

    /* Here is a race condition window when running on smp. */
    do {
        current->state = TASK_INTERRUPTIBLE;
        schedule_timeout(1);
    } while(atomic_read(&time_enter_count));
}

makefile:
               gcc -c -D__KERNEL__ -DMODULE -I/lib/modules/`uname
-r`/build/include ro.c
               ld -r -o mod.o ro.o --defsym zero=0
