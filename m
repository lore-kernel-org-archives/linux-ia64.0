From: JinShan Xiong <jinshan.xiong@gmail.com>
Date: Thu, 27 Jan 2005 12:29:49 +0000
Subject: Re: About intercepting linux system call
Message-Id: <b3b26beb050127042926372fe@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <b3b26beb05012620543066d40@mail.gmail.com>
In-Reply-To: <b3b26beb05012620543066d40@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I think I was not used the stub code correctly.

JinShan


On Thu, 27 Jan 2005 15:17:30 +0800, JinShan Xiong
<jinshan.xiong@gmail.com> wrote:
> Hi,
> 
> Seems to near our target;-).  But the kernel crashed too while I
> installed the following module.
> 
> I am downloading ski, thank you, David.
> 
> JinShan
> 
> Here is my test file:/* vi: set ts=4 sw=4 expandtab: */
> 
> #include <linux/config.h>
> #include <linux/kernel.h>
> #include <linux/module.h>
> #include <linux/unistd.h>
> #include <linux/sched.h>
> #include <asm/pgtable.h>
> #include <linux/vmalloc.h>
> #include <linux/mm.h>
> #include <asm/uaccess.h>
> 
> extern unsigned long sys_call_table[];
> 
> static long (*old_time)(struct timeval *, struct timezone *);
> extern void new_time_stub(void);
> //extern unsigned long new_time_stub;
> 
> asm (
> "        .proc new_time_stub\n"
> "new_time_stub:"
> "       .prologue\n"
> "       .regstk 2, 3, 2, 0\n"
> "       .save ar.pfs, loc1\n"
> "       alloc loc1 = ar.pfs, 2, 3, 2, 0\n"
> "       movl r2 = @gprel(zero);;\n"
> "       .save rp, loc0\n"
> "       mov loc0 = rp\n"
> "       mov loc2 = gp\n"
> "       sub gp = r0, r2\n"
> "       mov out0 = in0\n"
> "       mov out1 = in1\n"
> "       br.call.sptk.many rp = new_time\n"
> "1:      mov rp = loc0\n"
> "       mov ar.pfs = loc1\n"
> "       mov gp = loc2\n"
> "       br.ret.sptk.many rp\n"
> "       .endp\n"
> );
> 
> long new_time(struct timeval *tv, struct timezone *tz)
> {
>     if (tv) {
>         struct timeval ktv;
>         do_gettimeofday(&ktv);
>         if (copy_to_user(tv, &ktv, sizeof(ktv)))
>             return -EFAULT;
>     }
>     if (tz) {
>         extern struct timezone sys_tz;
>         if (copy_to_user(tz, &sys_tz, sizeof(sys_tz)))
>             return -EFAULT;
>     }
>     return 0;
> }
> 
> int init_module(void)
> {
>     printk("new_time_stub is %llx\n", new_time_stub);
>     old_time = sys_call_table[__NR_gettimeofday - 1024];
>     sys_call_table[__NR_gettimeofday - 1024] = new_time_stub;
>     return 0;
> }
> 
> void cleanup_module()
> {
>     /* should restore syscall here! */
>     sys_call_table[__NR_gettimeofday - 1024] = old_time;
>     printk("Byebye!\n");
> }
> 
> and makefile:
> all:
>     gcc -D__KERNEL__ -DMODULE -I/lib/modules/`uname -r`/build/include -c ro.c
>     ld -r -o mod.o ro.o --defsym zero=0
> 
> kernel dump msg:
> - - - - - - - - - - - - Live Console - - - - - - - - - - - -
> new_time_stub is a000000000318f70
> klogd[784]: IA-64 Illegal operation fault 0
> --> .opd [mod] 0x21 <--
> 
> Pid: 784, comm:                klogd
> psr : 0000121008026018 ifs : 8000000000000002 ip  :
> [<a000000000318f71>]    Tainted: P
> unat: 0000000000000000 pfs : 0000000000000002 rsc : 0000000000000003
> rnat: 0000000000000000 bsps: 0000000000000000 pr  : 80000000ff600199
> ldrs: 0000000000000000 ccv : 00000000000001ad fpsr: 0009804c0270033f
> b0  : e00000000440df00 b6  : e000000004402f60 b7  : e00000000440d990
> f6  : 1003ecccccccccccccccd f7  : 1003e0000000000000004
> f8  : 1003e0000000000000064 f9  : 1003ea3d70a3d70a3d70b
> r1  : e000000004cf5760 r2  : 0000000000000000 r3  : 00000000000000ff
> r8  : e0000040fc4a7f00 r9  : 20000000002a4fc0 r10 : 0000000000000000
> r11 : 6000000000009d50 r12 : e0000040fc4a7e60 r13 : e0000040fc4a0000
> r14 : e000000000000000 r15 : e00000000440df00 r16 : e0000040fc4a7e70
> r17 : e0000040fc4a7e78 r18 : 00001413085a6010 r19 : 200000000018f4d0
> r20 : 0000000000000002 r21 : 0000000000255b0a r22 : 00000000005b0a3e
> r23 : 60000fffffffaf20 r24 : 0a0a0a0a0a2f5100 r25 : 0a0a0a0a0a0a0a0a
> r26 : 0000000000000048 r27 : 0000000000000000 r28 : 0000000000000018
> r29 : 0000000000000028 r30 : 0000000000000008 r31 : 0000000000000000
> 
> Call Trace: [<e000000004414910>] sp=0xe0000040fc4a79c0 bsp=0xe0000040fc4a12c0
> decoded to show_stack [kernel] 0x50
> [<e000000004415140>] sp=0xe0000040fc4a7b80 bsp=0xe0000040fc4a1268
> decoded to show_regs [kernel] 0x7c0
> [<e00000000442fd90>] sp=0xe0000040fc4a7ba0 bsp=0xe0000040fc4a1240
> decoded to die [kernel] 0x190
> [<e00000000442fe60>] sp=0xe0000040fc4a7ba0 bsp=0xe0000040fc4a1218
> decoded to die_if_kernel [kernel] 0x40
> [<e000000004430af0>] sp=0xe0000040fc4a7ba0 bsp=0xe0000040fc4a1200
> decoded to ia64_illegal_op_fault [kernel] 0x50
> [<e000000004403ed0>] sp=0xe0000040fc4a7cc0 bsp=0xe0000040fc4a1200
> decoded to dispatch_illegal_op_fault [kernel] 0x2b0
>  <0>Kernel panic: not continuing
> bash[1192]: IA-64 Illegal operation fault 0
> ....
> 
> 
> On Wed, 26 Jan 2005 21:32:49 -0800, David Mosberger
> <davidm@napali.hpl.hp.com> wrote:
> > Hi JinShan,
> >
> > >>>>> On Thu, 27 Jan 2005 12:54:40 +0800, JinShan Xiong <jinshan.xiong@gmail.com> said:
> >
> >   JinShan> Hi all, i just want to intercept ia64 linux kernel's
> >   JinShan> syscall entry. I remapped the physical page contained
> >   JinShan> syscall table to a new read/write page in a vmalloc
> >   JinShan> region(0xa0000...) since ia64 linux kernel has been linked
> >   JinShan> the syscall table into a .rodata section, Yes, I can modify
> >   JinShan> the syscall entry now, but the kernel crashed after the
> >   JinShan> kernel entered into my own new function.
> >
> >   JinShan> I run my test code on a Hp-ia64 machine with redhat AS-2.1e
> >   JinShan> installed, and the kernel is 2.4.18-e.47smp.
> >
> >   JinShan> I am not familiar with ia64 architecture, please help me,
> >   JinShan> thanks.
> >
> > Hi JinShan,
> >
> > There is no need to copy the syscall table to a writable area.  On
> > ia64, the kernel memory is writable (for the kernel) by default.  I
> > think the problem in your code is due to the gp register not being
> > setup properly before calling into the module.  Each module gets its
> > own global-offset-table (GOT) so the gp needs to be loaded up before
> > calling any of the module's C function.  However, the kernel assumes
> > that all system calls are implemented in the kernel proper, so it
> > bypasses the gp-loading that would normally happen when calling
> > through a function-pointer.
> >
> > This can be fixed with a little stub which takes care of saving the
> > old gp-value, loading the modules gp, calling the real function and,
> > upon return, restoring the original gp-value.
> >
> > I think something like this might work:
> >
> >         .proc new_time_stub
> > new_time_stub:
> >         .prologue
> >         .regstk 2, 3, 2, 0
> >         .save ar.pfs, loc1
> >         alloc loc1 = ar.pfs, 2, 3, 2, 0
> >         movl r2 = @gprel(zero);;
> >         .save rp, loc0
> >         mov loc0 = rp
> >         mov loc2 = gp
> >         sub gp = r0, r2
> >         mov out0 = in0
> >         mov out1 = in1
> >         br.call.sptk.many rp = new_time
> > 1:      mov rp = loc0
> >         mov ar.pfs = loc1
> >         mov gp = loc2
> >         br.ret.sptk.many rp
> >         .endp
> >
> > Here, "zero" needs to be a symbol that the linker resolves to 0.  You
> > can define "zero" either via a linker script or by passing the linker
> > the option "--defsym zero=0".  It may not be the most elegant way to
> > get the GP value, but it ought to work both on 2.4 and 2.6 (which use
> > different module loaders).
> >
> > Having said that, two caveats:
> >
> >  - In 2.6, sys_call_table is no longer exported, so your code can't
> >    work (and that's intentional, see below).
> 
> I always put the sys_call_table address as a module parameter into
> kernel in version above 2.4.20, hehe. Ugly?
> 
> >
> >  - Kernel developers generally frown on modules that try to intercept
> >    syscalls.  For one thing, it's potentially racy in an SMP
> >    environment and for another, it's questionable whether it's even
> >    legal to do so, at least if the module is proprietary (not offering
> >    a legal opinion here, just raising a potential red flag).
> 
> Nod. I am very happy to export our kernel module source code under GPL license.
> 
> >
> > On a related topic, you may find it easier to develop such code with
> > the Ski simulator [1].  It's very easy to setup and would let you
> > single-step through the code in question, so you can see exactly
> > what's going on.
> >
> >         --david
> >
> > [1] http://www.hpl.hp.com/research/linux/ski/
> >
>
