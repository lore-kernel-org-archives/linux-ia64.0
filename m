From: Luming Yu <luming.yu@gmail.com>
Date: Fri, 04 Dec 2009 07:29:04 +0000
Subject: Re: [RFC PATCH] Add TRACE_IRQFLAGS_SUPPORT, LOCKDEP_SUPPORT then
Message-Id: <3877989d0912032329u7c05a761wfdd5c7000b43218d@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="0016368e26de018cbc0479e2102b"
List-Id: <linux-ia64.vger.kernel.org>
References: <3877989d0908272018va6ee8f7n7ab2838fdf1b26e6@mail.gmail.com>
	 <20090828062212.GB11552@elte.hu>
In-Reply-To: <20090828062212.GB11552@elte.hu>
To: Ingo Molnar <mingo@elte.hu>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Hellwig <hch@infradead.org>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, "Yu, Fenghua" <fenghua.yu@intel.com>, "Luck, Tony" <tony.luck@intel.com>, Felix Blyakher <felixb@sgi.com>, Shaohua Li <shaohua.li@intel.com>, Bob Picco <bob.picco@hp.com>

--0016368e26de018cbc0479e2102b
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Sorry for later response, hope we can make it in -33-rc
I just have time update the patch based on your comments
and known issues not fixed in previous patch.

>> -#define PERCPU_PAGE_SHIFT =C2=A0 =C2=A016 =C2=A0 =C2=A0 =C2=A0/* log2()=
 of max. size of per-CPU area */
>> +#define PERCPU_PAGE_SHIFT =C2=A0 =C2=A020 =C2=A0 =C2=A0 =C2=A0/*16 log2=
() of max. size of per-CPU area */
>
> Why was this seemingly unrelated change done in a lockdep patch?

Tony has answered it.

>>
>> +config LOCKDEP_SUPPORT
>> + =C2=A0 =C2=A0 bool
>> + =C2=A0 =C2=A0 default y
>> +
>> +config STACKTRACE_SUPPORT
>> + =C2=A0 =C2=A0 bool
>> + =C2=A0 =C2=A0 default y
>
> The (shorter) form we generally use when architectures enable a
> feature is:
>
> =C2=A0config LOCKDEP_SUPPORT
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 def_bool y

Updated in new patch.

>
> =C2=A0config STACKTRACE_SUPPORT
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 def_bool y
>
> ( Separate cleanup patch: it might make sense to offer this in
> =C2=A0generic code and just select a HAVE_LOCKDEP_SUPPORT flag. This
> =C2=A0affects all lockdep architectures so should be handled
> =C2=A0separately. )

Will update in an incremental patch
once this patch is in.

>> +config TRACE_IRQFLAGS_SUPPORT
>> + =C2=A0 =C2=A0 bool
>> + =C2=A0 =C2=A0 default y
>
> (same comment as above.)

Updated in new patch.

>> +void save_stack_trace(struct stack_trace *trace)
>> +{
>> +}
>> +EXPORT_SYMBOL(save_stack_trace);
>> +void __ia64_save_stack_nonlocal(struct stack_trace *trace)
>
> (nit: missing newline)

Updated in new patch

>
>> +{
>> +}
>> +EXPORT_SYMBOL(__ia64_save_stack_nonlocal);
>
> also, these functions should be implemented, for lockdep reports to
> be readable. Generally this is done by librarizing the dump_stack()
> et al architecture code into stacktrace.c.

Yes, Will update in an incremental patch once this patch is in.

>
>> diff -BruN linux-2.6.31-rc6/include/asm-ia64/irqflags.h
>> linux-2.6.31-rc6-lockdep/include/asm-ia64/irqflags.h
>> --- linux-2.6.31-rc6/include/asm-ia64/irqflags.h =C2=A0 =C2=A0 =C2=A0196=
9-12-31
>> 16:00:00.000000000 -0800
>> +++ linux-2.6.31-rc6-lockdep/include/asm-ia64/irqflags.h =C2=A0 =C2=A0 =
=C2=A02009-08-23
>> 18:59:14.000000000 -0700
>> @@ -0,0 +1,92 @@
>> +#ifndef _ASM_IRQFLAGS_H
>> +#define _ASM_IRQFLAGS_H
>> +#include <asm/kregs.h>
>> +#include <asm/pal.h>
>> +/*
>> + * The group barrier in front of the rsm & ssm are necessary to ensure
>> + * that none of the previous instructions in the same group are
>> + * affected by the rsm/ssm.
>> + */
>> +/* For spinlocks etc */
>> +
>
> ( nit: looks a bit disorganized - could be merged into a single
> =C2=A0 =C2=A0 =C2=A0 comment block? )

Updated in new patch

>
>> +/*
>> + * - clearing psr.i is implicitly serialized (visible by next insn)
>> + * - setting psr.i requires data serialization
>> + * - we need a stop-bit before reading PSR because we sometimes
>> + * =C2=A0 write a floating-point register right before reading the PSR
>> + * =C2=A0 and that writes to PSR.mfl
>> + */
>> +#define __local_irq_save(x) =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0\
>> +do { =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 \
>> + =C2=A0 =C2=A0 ia64_stop(); =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0\
>> + =C2=A0 =C2=A0 (x) =3D ia64_getreg(_IA64_REG_PSR); =C2=A0 =C2=A0 =C2=A0=
 \
>> + =C2=A0 =C2=A0 ia64_stop(); =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0\
>> + =C2=A0 =C2=A0 ia64_rsm(IA64_PSR_I); =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 \
>> +} while (0)
>
> please use C inline functions for all of irqflags.h (x86 does that
> too). Macros have all sorts of disadvantages: they are harder to
> read and also double evaluation side-effects are harder to keep
> under control.

Good point. There are a lot of such kind of Macros in IA64
architecture waiting thoroughly clean up. May I update this
part later?

>> +
>> +# define raw_local_irq_disable() =C2=A0 =C2=A0 do { unsigned long x;
>> raw_local_irq_save(x); } while (0)
>
> ( the patch seems line-wrapped, see Documentation/email-clients.txt
> =C2=A0about how to send plain-text patches. )

I'm sorry for this. Please apply attached patch.
I use web gmail  since it is the most convenient way to me.

>> -#define MAX_LOCKDEP_KEYS_BITS =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A013
>> +#define MAX_LOCKDEP_KEYS_BITS =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A010
>
> Why did you have to do this bit?

Without dynamic allocation both in Lockdep code and
ia64 architecture in place, 13 bits requires far moe
size than ia64 can support in Per CPU area (1M)

Tony, is it correct?

>>
>> =C2=A0config DEBUG_LOCKDEP
>> =C2=A0 =C2=A0 =C2=A0 bool "Lock dependency engine debugging"
>> - =C2=A0 =C2=A0 depends on DEBUG_KERNEL && LOCKDEP
>> + =C2=A0 =C2=A0 depends on DEBUG_KERNEL && LOCKDEP && !IA64
>> =C2=A0 =C2=A0 =C2=A0 help
>
> That should be fixed (and this chunk will then not be needed) before
> this is merged.

Updated in new patch

>
> Also, a few general comments:
>
> =C2=A0- There's no lockdep_sys_exit support implemented. (This callback
> =C2=A0 is needed to detect lock counts leaking to user-space. Just call
> =C2=A0 it in the return-from-syscall codepath(s).)

Updated in new patch. But Temporarily commented out in call site.
I tested it, but there is lock held before leaving kernel...
Will root cause, and fix the problem later.

>
> =C2=A0- There's no changes to exception code assembly AFAICS - such as
> =C2=A0 debug traps, special exceptions, etc. You should review all
> =C2=A0 places in the IA64 code where there's open-coded or
> =C2=A0 hardware-implicit enable-irqs or disable-irqs instructions, not
> =C2=A0 just the main local_irq_*() functions. A starting point would be:
>
> =C2=A0 =C2=A0 =C2=A0git grep IA64_PSR_I arch/ia64/ | grep .S:
>
> =C2=A0 but there may be instructions and trap entries where there's
> =C2=A0 implicit irq-flags behavior - those need to be examined too.

Updated some in assembly code that modify PSR.I bit.
But not all, because not all modifications of PSR.i bit
would be interesting to lockdep code..

>
> =C2=A0- Do kprobes work with this patch?

Tested, yes.

>
> =C2=A0- No NMI support AFAICS - all NMI codepaths should be exempted from
> =C2=A0 irqflags coverage.

Good point, I need to find out place to insert
nmi_enter and nmi_exit., and do some testing.
Not done yet.

Will update in an incremental patch after the patch is accepted.


>
> Thanks,
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Ingo

Thanks for review.

>


The following is some results with the new patch.

[root@localhost ~]# dmesg | head -2
Linux version 2.6.31 (root@localhost.localdomain) (gcc version 4.1.2
20071124 (Red Hat 4.1.2-42)) #1 SMP Thu Dec 3 16:35:07 PST 2009

[root@localhost ~]# dmesg | grep Kprobe
Kprobe smoke test started
Kprobe smoke test passed successfully

[root@localhost ~]# dmesg

.....
Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
... MAX_LOCKDEP_SUBCLASSES:  8
... MAX_LOCK_DEPTH:          48
... MAX_LOCKDEP_KEYS:        1023
... CLASSHASH_SIZE:          512
... MAX_LOCKDEP_ENTRIES:     16384
... MAX_LOCKDEP_CHAINS:      32768
... CHAINHASH_SIZE:          16384
 memory used by lock dependency info: 2679 kB
 per task-struct memory footprint: 2688 bytes
------------------------
| Locking API testsuite:
---------------------------------------------------------------------------=
-
                                 | spin |wlock |rlock |mutex | wsem | rsem =
|
  -------------------------------------------------------------------------=
-
                     A-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  =
|
                 A-B-B-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  =
|
             A-B-B-C-C-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  =
|
             A-B-C-A-B-C deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  =
|
         A-B-B-C-C-D-D-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  =
|
         A-B-C-D-B-D-D-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  =
|
         A-B-C-D-B-C-D-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  =
|
                    double unlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  =
|
                  initialize held:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  =
|
                 bad unlock order:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  =
|
  -------------------------------------------------------------------------=
-
              recursive read-lock:             |  ok  |             |  ok  =
|
           recursive read-lock #2:             |  ok  |             |  ok  =
|
            mixed read-write-lock:             |  ok  |             |  ok  =
|
            mixed write-read-lock:             |  ok  |             |  ok  =
|
  -------------------------------------------------------------------------=
-
     hard-irqs-on + irq-safe-A/12:  ok  |  ok  |  ok  |
     soft-irqs-on + irq-safe-A/12:  ok  |  ok  |  ok  |
     hard-irqs-on + irq-safe-A/21:  ok  |  ok  |  ok  |
     soft-irqs-on + irq-safe-A/21:  ok  |  ok  |  ok  |
       sirq-safe-A =3D> hirqs-on/12:  ok  |  ok  |  ok  |
       sirq-safe-A =3D> hirqs-on/21:  ok  |  ok  |  ok  |
         hard-safe-A + irqs-on/12:  ok  |  ok  |  ok  |
         soft-safe-A + irqs-on/12:  ok  |  ok  |  ok  |
         hard-safe-A + irqs-on/21:  ok  |  ok  |  ok  |
         soft-safe-A + irqs-on/21:  ok  |  ok  |  ok  |
    hard-safe-A + unsafe-B #1/123:  ok  |  ok  |  ok  |
    soft-safe-A + unsafe-B #1/123:  ok  |  ok  |  ok  |
    hard-safe-A + unsafe-B #1/132:  ok  |  ok  |  ok  |
    soft-safe-A + unsafe-B #1/132:  ok  |  ok  |  ok  |
    hard-safe-A + unsafe-B #1/213:  ok  |  ok  |  ok  |
    soft-safe-A + unsafe-B #1/213:  ok  |  ok  |  ok  |
    hard-safe-A + unsafe-B #1/231:  ok  |  ok  |  ok  |
    soft-safe-A + unsafe-B #1/231:  ok  |  ok  |  ok  |
    hard-safe-A + unsafe-B #1/312:  ok  |  ok  |  ok  |
    soft-safe-A + unsafe-B #1/312:  ok  |  ok  |  ok  |
    hard-safe-A + unsafe-B #1/321:  ok  |  ok  |  ok  |
    soft-safe-A + unsafe-B #1/321:  ok  |  ok  |  ok  |
    hard-safe-A + unsafe-B #2/123:  ok  |  ok  |  ok  |
    soft-safe-A + unsafe-B #2/123:  ok  |  ok  |  ok  |
    hard-safe-A + unsafe-B #2/132:  ok  |  ok  |  ok  |
    soft-safe-A + unsafe-B #2/132:  ok  |  ok  |  ok  |
    hard-safe-A + unsafe-B #2/213:  ok  |  ok  |  ok  |
    soft-safe-A + unsafe-B #2/213:  ok  |  ok  |  ok  |
    hard-safe-A + unsafe-B #2/231:  ok  |  ok  |  ok  |
    soft-safe-A + unsafe-B #2/231:  ok  |  ok  |  ok  |
    hard-safe-A + unsafe-B #2/312:  ok  |  ok  |  ok  |
    soft-safe-A + unsafe-B #2/312:  ok  |  ok  |  ok  |
    hard-safe-A + unsafe-B #2/321:  ok  |  ok  |  ok  |
    soft-safe-A + unsafe-B #2/321:  ok  |  ok  |  ok  |
      hard-irq lock-inversion/123:  ok  |  ok  |  ok  |
      soft-irq lock-inversion/123:  ok  |  ok  |  ok  |
      hard-irq lock-inversion/132:  ok  |  ok  |  ok  |
      soft-irq lock-inversion/132:  ok  |  ok  |  ok  |
      hard-irq lock-inversion/213:  ok  |  ok  |  ok  |
      soft-irq lock-inversion/213:  ok  |  ok  |  ok  |
      hard-irq lock-inversion/231:  ok  |  ok  |  ok  |
      soft-irq lock-inversion/231:  ok  |  ok  |  ok  |
      hard-irq lock-inversion/312:  ok  |  ok  |  ok  |
      soft-irq lock-inversion/312:  ok  |  ok  |  ok  |
      hard-irq lock-inversion/321:  ok  |  ok  |  ok  |
      soft-irq lock-inversion/321:  ok  |  ok  |  ok  |
      hard-irq read-recursion/123:  ok  |
      soft-irq read-recursion/123:  ok  |
      hard-irq read-recursion/132:  ok  |
      soft-irq read-recursion/132:  ok  |
      hard-irq read-recursion/213:  ok  |
      soft-irq read-recursion/213:  ok  |
      hard-irq read-recursion/231:  ok  |
      soft-irq read-recursion/231:  ok  |
      hard-irq read-recursion/312:  ok  |
      soft-irq read-recursion/312:  ok  |
      hard-irq read-recursion/321:  ok  |
      soft-irq read-recursion/321:  ok  |
-------------------------------------------------------
Good, all 218 testcases passed! |

[root@localhost ~]# cat /proc/lockdep_stats
 lock-classes:                          546 [max: 1023]
 direct dependencies:                   572 [max: 16384]
 indirect dependencies:                 455
 all direct dependencies:              2132
 dependency chains:                    1194 [max: 32768]
 dependency chain hlocks:              1928 [max: 163840]
 in-hardirq chains:                       7
 in-softirq chains:                       3
 in-process chains:                     317
 stack-trace entries:                     0 [max: 262144]
 combined max dependencies:           10176
 hardirq-safe locks:                      8
 hardirq-unsafe locks:                   65
 softirq-safe locks:                     10
 softirq-unsafe locks:                   64
 irq-safe locks:                         16
 irq-unsafe locks:                       65
 hardirq-read-safe locks:                 0
 hardirq-read-unsafe locks:               5
 softirq-read-safe locks:                 0
 softirq-read-unsafe locks:               5
 irq-read-safe locks:                     0
 irq-read-unsafe locks:                   5
 uncategorized locks:                    41
 unused locks:                            0
 max locking depth:                       5
 max recursion depth:                     4
 debug_locks:                             0



Known issues:
0. dynamic allocate per CPU area in lockdep.
1. lock held in leave kernel.
2. enabling CONFIG_DEBUG_LOCKDEP triggers the lockdep warning.

WARNING: at kernel/lockdep.c:2901 check_flags+0x1c0/0x480()
Modules linked in:

Call Trace:
 [<a000000100017310>] show_stack+0x70/0xc0
                                sp=3Da000000100be7c40 bsp=3Da000000100be1e0=
0
 [<a0000001000173b0>] dump_stack+0x50/0x80
                                sp=3Da000000100be7e10 bsp=3Da000000100be1dd=
8
 [<a000000100095750>] warn_slowpath_common+0xf0/0x140
                                sp=3Da000000100be7e10 bsp=3Da000000100be1d9=
8
 [<a000000100095800>] warn_slowpath_null+0x60/0x80
                                sp=3Da000000100be7e10 bsp=3Da000000100be1d6=
8
 [<a0000001000ecf00>] check_flags+0x1c0/0x480
                                sp=3Da000000100be7e10 bsp=3Da000000100be1d4=
0
 [<a0000001000f34a0>] lockdep_trace_alloc+0x60/0x160
                                sp=3Da000000100be7e10 bsp=3Da000000100be1d1=
0
 [<a0000001001ec2d0>] kmem_cache_alloc_node+0x70/0x440
                                sp=3Da000000100be7e10 bsp=3Da000000100be1cb=
8
 [<a0000001001ec740>] __kmalloc_node+0xa0/0x1a0
                                sp=3Da000000100be7e10 bsp=3Da000000100be1c6=
8
 [<a0000001001ee7e0>] alloc_arraycache+0x60/0xe0
                                sp=3Da000000100be7e20 bsp=3Da000000100be1c2=
8
 [<a0000001001f02c0>] alloc_alien_cache+0x160/0x280
                                sp=3Da000000100be7e20 bsp=3Da000000100be1bd=
0
 [<a0000001001f0960>] do_tune_cpucache+0x580/0xba0
                                sp=3Da000000100be7e20 bsp=3Da000000100be1b5=
8
 [<a0000001001f1470>] enable_cpucache+0x130/0x200
                                sp=3Da000000100be7e20 bsp=3Da000000100be1b2=
0
 [<a000000100b06c20>] kmem_cache_init_late+0x60/0x3e0
                                sp=3Da000000100be7e20 bsp=3Da000000100be1ae=
0
 [<a000000100ae12b0>] start_kernel+0x550/0x940
                                sp=3Da000000100be7e20 bsp=3Da000000100be1a6=
0
 [<a000000100841a60>] _start+0x760/0x780
                                sp=3Da000000100be7e30 bsp=3Da000000100be19c=
0
---[ end trace 4eaa2a86a8e2da22 ]---
possible reason: unannotated irqs-on.


Please review patch update. If make sense, please apply.

Ps. The patch is enclosed in attachment. The inline one
is c&p of it for reading.


Thanks,
Luming

Signed-off-by: Bob Picco <bob.picco@hp.com>
Signed-off-by: Yu Luming <luming.yu@intel.com>

 arch/ia64/Kconfig                  |    6 ++
 arch/ia64/Kconfig.debug            |    3 +
 arch/ia64/include/asm/irqflags.h   |  101 ++++++++++++++++++++++++++++++++=
+++++
 arch/ia64/include/asm/page.h       |    2
 arch/ia64/include/asm/rwsem.h      |   27 ++++++---
 arch/ia64/include/asm/stacktrace.h |    7 ++
 arch/ia64/include/asm/system.h     |   84 ------------------------------
 arch/ia64/kernel/Makefile          |    1
 arch/ia64/kernel/entry.S           |    6 ++
 arch/ia64/kernel/ivt.S             |   29 ++++++++++
 arch/ia64/kernel/process.c         |    6 +-
 arch/ia64/kernel/setup.c           |    4 +
 arch/ia64/kernel/smpboot.c         |    2
 arch/ia64/kernel/stacktrace.c      |   24 ++++++++
 arch/ia64/kernel/time.c            |    4 -
 include/linux/lockdep.h            |    2

diff -BruN linux-2.6.31/arch/ia64/include/asm/irqflags.h
testing/arch/ia64/include/asm/irqflags.h
--- linux-2.6.31/arch/ia64/include/asm/irqflags.h	1969-12-31
16:00:00.000000000 -0800
+++ testing/arch/ia64/include/asm/irqflags.h	2009-12-03 15:40:45.000000000 =
-0800
@@ -0,0 +1,101 @@
+#ifndef _ASM_IRQFLAGS_H
+#define _ASM_IRQFLAGS_H
+#include <asm/kregs.h>
+#include <asm/pal.h>
+/*
+ * The group barrier in front of the rsm & ssm are necessary to ensure
+ * that none of the previous instructions in the same group are
+ * affected by the rsm/ssm.
+ *
+ * For spinlocks etc
+ * - clearing psr.i is implicitly serialized (visible by next insn)
+ * - setting psr.i requires data serialization
+ * - we need a stop-bit before reading PSR because we sometimes
+ *   write a floating-point register right before reading the PSR
+ *   and that writes to PSR.mfl
+ */
+#define __local_irq_save(x)			\
+do {						\
+	ia64_stop();				\
+	(x) =3D ia64_getreg(_IA64_REG_PSR);	\
+	ia64_stop();				\
+	ia64_rsm(IA64_PSR_I);			\
+} while (0)
+
+#define __local_irq_disable()			\
+do {						\
+	ia64_stop();				\
+	ia64_rsm(IA64_PSR_I);			\
+} while (0)
+
+#define __local_irq_restore(x)	ia64_intrin_local_irq_restore((x) & IA64_PS=
R_I)
+
+#ifdef CONFIG_IA64_DEBUG_IRQ
+
+  extern unsigned long last_cli_ip;
+
+# define __save_ip()		last_cli_ip =3D ia64_getreg(_IA64_REG_IP)
+
+# define raw_local_irq_save(x)					\
+do {								\
+	unsigned long psr;					\
+								\
+	__local_irq_save(psr);					\
+	if (psr & IA64_PSR_I)					\
+		__save_ip();					\
+	(x) =3D psr;						\
+} while (0)
+
+# define raw_local_irq_disable()	do { unsigned long x;
raw_local_irq_save(x); } while (0)
+
+# define raw_local_irq_restore(x)					\
+do {								\
+	unsigned long old_psr, psr =3D (x);			\
+								\
+	local_save_flags(old_psr);				\
+	__local_irq_restore(psr);				\
+	if ((old_psr & IA64_PSR_I) && !(psr & IA64_PSR_I))	\
+		__save_ip();					\
+} while (0)
+
+#else /* !CONFIG_IA64_DEBUG_IRQ */
+# define raw_local_irq_save(x)	__local_irq_save(x)
+# define raw_local_irq_disable()	__local_irq_disable()
+# define raw_local_irq_restore(x)	__local_irq_restore(x)
+#endif /* !CONFIG_IA64_DEBUG_IRQ */
+
+#define raw_local_irq_enable()	({ ia64_stop(); ia64_ssm(IA64_PSR_I);
ia64_srlz_d(); })
+#define raw_local_save_flags(flags)	({ ia64_stop(); (flags) =3D
ia64_getreg(_IA64_REG_PSR); })
+
+#define raw_irqs_disabled()				\
+({						\
+	unsigned long __ia64_id_flags;		\
+	raw_local_save_flags(__ia64_id_flags);	\
+	(__ia64_id_flags & IA64_PSR_I) =3D=3D 0;	\
+})
+
+#define raw_safe_halt()         ia64_pal_halt_light()    /* PAL_HALT_LIGHT=
 */
+#define raw_irqs_disabled_flags(flags)	\
+({						\
+	(int)((flags) & IA64_PSR_I) =3D=3D 0;	\
+})
+=09
+#ifdef CONFIG_TRACE_IRQFLAGS
+#define TRACE_IRQS_ON br.call.sptk.many b0=3Dtrace_hardirqs_on
+#define TRACE_IRQS_OFF br.call.sptk.many b0=3Dtrace_hardirqs_off
+#else
+#define TRACE_IRQS_ON
+#define TRACE_IRQS_OFF
+#endif
+
+#define ARCH_LOCKDEP_SYS_EXIT br.call.sptk.many rp=3Dlockdep_sys_exit
+
+#ifdef CONFIG_DEBUG_LOCK_ALLOC
+#define LOCKDEP_SYS_EXIT	ARCH_LOCKDEP_SYS_EXIT
+#else
+#define LOCKDEP_SYS_EXIT
+#endif
+
+#endif
+
+
diff -BruN linux-2.6.31/arch/ia64/include/asm/page.h
testing/arch/ia64/include/asm/page.h
--- linux-2.6.31/arch/ia64/include/asm/page.h	2009-09-09
15:13:59.000000000 -0700
+++ testing/arch/ia64/include/asm/page.h	2009-12-03 12:01:50.000000000 -080=
0
@@ -41,7 +41,7 @@
 #define PAGE_SIZE		(__IA64_UL_CONST(1) << PAGE_SHIFT)
 #define PAGE_MASK		(~(PAGE_SIZE - 1))

-#define PERCPU_PAGE_SHIFT	16	/* log2() of max. size of per-CPU area */
+#define PERCPU_PAGE_SHIFT	20	/*20 log2() of max. size of per-CPU area */
 #define PERCPU_PAGE_SIZE	(__IA64_UL_CONST(1) << PERCPU_PAGE_SHIFT)


diff -BruN linux-2.6.31/arch/ia64/include/asm/rwsem.h
testing/arch/ia64/include/asm/rwsem.h
--- linux-2.6.31/arch/ia64/include/asm/rwsem.h	2009-09-09
15:13:59.000000000 -0700
+++ testing/arch/ia64/include/asm/rwsem.h	2009-12-03 11:39:27.000000000 -08=
00
@@ -37,6 +37,9 @@
 	signed long		count;
 	spinlock_t		wait_lock;
 	struct list_head	wait_list;
+#ifdef CONFIG_DEBUG_LOCK_ALLOC
+	struct lockdep_map dep_map;
+#endif
 };

 #define RWSEM_UNLOCKED_VALUE		__IA64_UL_CONST(0x0000000000000000)
@@ -46,9 +49,15 @@
 #define RWSEM_ACTIVE_READ_BIAS		RWSEM_ACTIVE_BIAS
 #define RWSEM_ACTIVE_WRITE_BIAS		(RWSEM_WAITING_BIAS + RWSEM_ACTIVE_BIAS)

+#ifdef CONFIG_DEBUG_LOCK_ALLOC
+# define __RWSEM_DEP_MAP_INIT(lockname) , .dep_map =3D { .name =3D #lockna=
me }
+#else
+# define __RWSEM_DEP_MAP_INIT(lockname)
+#endif
+
 #define __RWSEM_INITIALIZER(name) \
 	{ RWSEM_UNLOCKED_VALUE, SPIN_LOCK_UNLOCKED, \
-	  LIST_HEAD_INIT((name).wait_list) }
+	  LIST_HEAD_INIT((name).wait_list) __RWSEM_DEP_MAP_INIT(name)}

 #define DECLARE_RWSEM(name) \
 	struct rw_semaphore name =3D __RWSEM_INITIALIZER(name)
@@ -58,13 +67,15 @@
 extern struct rw_semaphore *rwsem_wake(struct rw_semaphore *sem);
 extern struct rw_semaphore *rwsem_downgrade_wake(struct rw_semaphore *sem)=
;

-static inline void
-init_rwsem (struct rw_semaphore *sem)
-{
-	sem->count =3D RWSEM_UNLOCKED_VALUE;
-	spin_lock_init(&sem->wait_lock);
-	INIT_LIST_HEAD(&sem->wait_list);
-}
+extern void __init_rwsem(struct rw_semaphore *sem, const char *name,
+			 struct lock_class_key *key);
+
+#define init_rwsem(sem)						\
+do {								\
+	static struct lock_class_key __key;			\
+								\
+	__init_rwsem((sem), #sem, &__key);			\
+} while (0)

 /*
  * lock for reading
diff -BruN linux-2.6.31/arch/ia64/include/asm/stacktrace.h
testing/arch/ia64/include/asm/stacktrace.h
--- linux-2.6.31/arch/ia64/include/asm/stacktrace.h	1969-12-31
16:00:00.000000000 -0800
+++ testing/arch/ia64/include/asm/stacktrace.h	2009-12-03
12:32:58.000000000 -0800
@@ -0,0 +1,7 @@
+#ifndef _ASM_STACKTRACE_H
+#define _ASM_STACKTRACE_H 1
+
+/* Generic stack tracer with callbacks */
+
+
+#endif
diff -BruN linux-2.6.31/arch/ia64/include/asm/system.h
testing/arch/ia64/include/asm/system.h
--- linux-2.6.31/arch/ia64/include/asm/system.h	2009-09-09
15:13:59.000000000 -0700
+++ testing/arch/ia64/include/asm/system.h	2009-12-02 21:56:56.000000000 -0=
800
@@ -107,88 +107,6 @@
  */
 #define set_mb(var, value)	do { (var) =3D (value); mb(); } while (0)

-#define safe_halt()         ia64_pal_halt_light()    /* PAL_HALT_LIGHT */
-
-/*
- * The group barrier in front of the rsm & ssm are necessary to ensure
- * that none of the previous instructions in the same group are
- * affected by the rsm/ssm.
- */
-/* For spinlocks etc */
-
-/*
- * - clearing psr.i is implicitly serialized (visible by next insn)
- * - setting psr.i requires data serialization
- * - we need a stop-bit before reading PSR because we sometimes
- *   write a floating-point register right before reading the PSR
- *   and that writes to PSR.mfl
- */
-#ifdef CONFIG_PARAVIRT
-#define __local_save_flags()	ia64_get_psr_i()
-#else
-#define __local_save_flags()	ia64_getreg(_IA64_REG_PSR)
-#endif
-
-#define __local_irq_save(x)			\
-do {						\
-	ia64_stop();				\
-	(x) =3D __local_save_flags();		\
-	ia64_stop();				\
-	ia64_rsm(IA64_PSR_I);			\
-} while (0)
-
-#define __local_irq_disable()			\
-do {						\
-	ia64_stop();				\
-	ia64_rsm(IA64_PSR_I);			\
-} while (0)
-
-#define __local_irq_restore(x)	ia64_intrin_local_irq_restore((x) & IA64_PS=
R_I)
-
-#ifdef CONFIG_IA64_DEBUG_IRQ
-
-  extern unsigned long last_cli_ip;
-
-# define __save_ip()		last_cli_ip =3D ia64_getreg(_IA64_REG_IP)
-
-# define local_irq_save(x)					\
-do {								\
-	unsigned long __psr;					\
-								\
-	__local_irq_save(__psr);				\
-	if (__psr & IA64_PSR_I)					\
-		__save_ip();					\
-	(x) =3D __psr;						\
-} while (0)
-
-# define local_irq_disable()	do { unsigned long __x;
local_irq_save(__x); } while (0)
-
-# define local_irq_restore(x)					\
-do {								\
-	unsigned long __old_psr, __psr =3D (x);			\
-								\
-	local_save_flags(__old_psr);				\
-	__local_irq_restore(__psr);				\
-	if ((__old_psr & IA64_PSR_I) && !(__psr & IA64_PSR_I))	\
-		__save_ip();					\
-} while (0)
-
-#else /* !CONFIG_IA64_DEBUG_IRQ */
-# define local_irq_save(x)	__local_irq_save(x)
-# define local_irq_disable()	__local_irq_disable()
-# define local_irq_restore(x)	__local_irq_restore(x)
-#endif /* !CONFIG_IA64_DEBUG_IRQ */
-
-#define local_irq_enable()	({ ia64_stop(); ia64_ssm(IA64_PSR_I);
ia64_srlz_d(); })
-#define local_save_flags(flags)	({ ia64_stop(); (flags) =3D
__local_save_flags(); })
-
-#define irqs_disabled()				\
-({						\
-	unsigned long __ia64_id_flags;		\
-	local_save_flags(__ia64_id_flags);	\
-	(__ia64_id_flags & IA64_PSR_I) =3D=3D 0;	\
-})
-
 #ifdef __KERNEL__

 #ifdef CONFIG_IA32_SUPPORT
@@ -274,7 +192,7 @@
 #define __ARCH_WANT_UNLOCKED_CTXSW
 #define ARCH_HAS_PREFETCH_SWITCH_STACK
 #define ia64_platform_is(x) (strcmp(x, platform_name) =3D=3D 0)
-
+#include <linux/irqflags.h>
 void cpu_idle_wait(void);

 #define arch_align_stack(x) (x)
diff -BruN linux-2.6.31/arch/ia64/Kconfig testing/arch/ia64/Kconfig
--- linux-2.6.31/arch/ia64/Kconfig	2009-09-09 15:13:59.000000000 -0700
+++ testing/arch/ia64/Kconfig	2009-12-03 11:43:38.000000000 -0800
@@ -143,6 +143,12 @@

 endif

+config LOCKDEP_SUPPORT
+	def_bool y
+
+config STACKTRACE_SUPPORT
+	def_bool y
+
 choice
 	prompt "System type"
 	default IA64_GENERIC
diff -BruN linux-2.6.31/arch/ia64/Kconfig.debug testing/arch/ia64/Kconfig.d=
ebug
--- linux-2.6.31/arch/ia64/Kconfig.debug	2009-09-09 15:13:59.000000000 -070=
0
+++ testing/arch/ia64/Kconfig.debug	2009-12-03 11:44:16.000000000 -0800
@@ -2,6 +2,9 @@

 source "lib/Kconfig.debug"

+config TRACE_IRQFLAGS_SUPPORT
+	def_bool y
+
 choice
 	prompt "Physical memory granularity"
 	default IA64_GRANULE_64MB
diff -BruN linux-2.6.31/arch/ia64/kernel/entry.S
testing/arch/ia64/kernel/entry.S
--- linux-2.6.31/arch/ia64/kernel/entry.S	2009-09-09 15:13:59.000000000 -07=
00
+++ testing/arch/ia64/kernel/entry.S	2009-12-03 12:55:53.000000000 -0800
@@ -48,6 +48,7 @@
 #include <asm/thread_info.h>
 #include <asm/unistd.h>
 #include <asm/ftrace.h>
+#include <asm/irqflags.h>

 #include "minstate.h"

@@ -897,6 +899,11 @@
 	cmp.eq p6,p0=3Dr21,r0		// p6 <- pUStk || (preempt_count =3D=3D 0)
 #else
 	RSM_PSR_I(pUStk, r17, r31)
+#if 0 //Todo: fix lock held when returning to user space
+	;;
+	LOCKDEP_SYS_EXIT
+	;;
+#endif
 	cmp.eq p0,pLvSys=3Dr0,r0		// pLvSys=3D0: leave from kernel
 (pUStk)	cmp.eq.unc p6,p0=3Dr0,r0		// p6 <- pUStk
 #endif
diff -BruN linux-2.6.31/arch/ia64/kernel/ivt.S testing/arch/ia64/kernel/ivt=
.S
--- linux-2.6.31/arch/ia64/kernel/ivt.S	2009-09-09 15:13:59.000000000 -0700
+++ testing/arch/ia64/kernel/ivt.S	2009-12-03 11:50:40.000000000 -0800
@@ -855,6 +855,11 @@
 	mov rp=3Dr3				// I0   set the real return addr
 (p10)	br.cond.spnt.many ia64_ret_from_syscall	// B    return if bad
call-frame or r15 is a NaT

+#ifdef TRACE_IRQFLAGS_SUPPORT
+	;;
+(p15)	br.call.sptk.many rp=3Dtrace_hardirqs_on
+	;;
+#endif
 	SSM_PSR_I(p15, p15, r16)		// M2   restore psr.i
 (p14)	br.call.sptk.many b6=3Db6			// B    invoke syscall-handker
(ignore return addr)
 	br.cond.spnt.many ia64_trace_syscall	// B	do syscall-tracing thingamagic
@@ -1555,6 +1560,11 @@
 	MOV_FROM_ISR(out1)
 	SSM_PSR_IC_AND_DEFAULT_BITS_AND_SRLZ_I(r14, r3)
 	adds r3=3D8,r2				// set up second base pointer
+#ifdef TRACE_IRQFLAGS_SUPPORT
+	;;
+(p15)	br.call.sptk.many rp=3Dtrace_hardirqs_on
+	;;
+#endif
 	SSM_PSR_I(p15, p15, r14)		// restore psr.i
 	movl r14=3Dia64_leave_kernel
 	;;
@@ -1582,6 +1592,11 @@

 	SSM_PSR_IC_AND_DEFAULT_BITS_AND_SRLZ_I(r15, r24)
 					// guarantee that interruption collection is on
+#ifdef TRACE_IRQFLAGS_SUPPORT
+	;;
+(p15)	br.call.sptk.many rp=3Dtrace_hardirqs_on
+	;;
+#endif
 	SSM_PSR_I(p15, p15, r15)	// restore psr.i
 	movl r15=3Dia64_leave_kernel
 	;;
@@ -1630,6 +1645,11 @@

 	SSM_PSR_IC_AND_DEFAULT_BITS_AND_SRLZ_I(r3, r24)
 						// guarantee that interruption collection is on
+#ifdef TRACE_IRQFLAGS_SUPPORT
+	;;
+(p15)	br.call.sptk.many rp=3Dtrace_hardirqs_on
+	;;
+#endif
 	SSM_PSR_I(p15, p15, r3)			// restore psr.i
 	adds r3=3D8,r2				// set up second base pointer
 	;;
@@ -1665,6 +1685,11 @@
 						// guarantee that interruption collection is on
 	mov out0=3Dr15
 	;;
+#ifdef TRACE_IRQFLAGS_SUPPORT
+	;;
+(p15)	br.call.sptk.many rp=3Dtrace_hardirqs_on
+	;;
+#endif
 	SSM_PSR_I(p15, p15, r3)			// restore psr.i
 	adds r3=3D8,r2				// set up second base pointer for SAVE_REST
 	;;
@@ -1733,7 +1758,11 @@
 	MOV_FROM_ISR(r14)
 	SSM_PSR_IC_AND_DEFAULT_BITS_AND_SRLZ_I(r3, r24)
 				// guarantee that interruption collection is on
+#ifdef TRACE_IRQFLAGS_SUPPORT
 	;;
+(p15)	br.call.sptk.many rp=3Dtrace_hardirqs_on
+	;;
+#endif
 	SSM_PSR_I(p15, p15, r3)
 	adds r3=3D8,r2		// Base pointer for SAVE_REST
 	;;
diff -BruN linux-2.6.31/arch/ia64/kernel/Makefile
testing/arch/ia64/kernel/Makefile
--- linux-2.6.31/arch/ia64/kernel/Makefile	2009-09-09 15:13:59.000000000 -0=
700
+++ testing/arch/ia64/kernel/Makefile	2009-12-02 21:56:56.000000000 -0800
@@ -40,6 +40,7 @@
 obj-$(CONFIG_PCI_MSI)		+=3D msi_ia64.o
 mca_recovery-y			+=3D mca_drv.o mca_drv_asm.o
 obj-$(CONFIG_IA64_MC_ERR_INJECT)+=3D err_inject.o
+obj-$(CONFIG_STACKTRACE)	+=3D stacktrace.o

 obj-$(CONFIG_PARAVIRT)		+=3D paravirt.o paravirtentry.o \
 				   paravirt_patch.o
diff -BruN linux-2.6.31/arch/ia64/kernel/process.c
testing/arch/ia64/kernel/process.c
--- linux-2.6.31/arch/ia64/kernel/process.c	2009-09-09 15:13:59.000000000 -=
0700
+++ testing/arch/ia64/kernel/process.c	2009-12-03 11:51:28.000000000 -0800
@@ -225,14 +225,14 @@
 void
 default_idle (void)
 {
-	local_irq_enable();
+	raw_local_irq_enable();
 	while (!need_resched()) {
 		if (can_do_pal_halt) {
-			local_irq_disable();
+			raw_local_irq_disable();
 			if (!need_resched()) {
 				safe_halt();
 			}
-			local_irq_enable();
+			raw_local_irq_enable();
 		} else
 			cpu_relax();
 	}
diff -BruN linux-2.6.31/arch/ia64/kernel/setup.c
testing/arch/ia64/kernel/setup.c
--- linux-2.6.31/arch/ia64/kernel/setup.c	2009-09-09 15:13:59.000000000 -07=
00
+++ testing/arch/ia64/kernel/setup.c	2009-12-03 23:14:56.000000000 -0800
@@ -1021,7 +1021,11 @@
 	BUG_ON(current->mm);

 	ia64_mmu_init(ia64_imva(cpu_data));
+
+	/* Temporarily suppress lockdep WARN_ON irqs disabled*/
+	lockdep_off();
 	ia64_mca_cpu_init(ia64_imva(cpu_data));
+	lockdep_on();

 #ifdef CONFIG_IA32_SUPPORT
 	ia32_cpu_init();
diff -BruN linux-2.6.31/arch/ia64/kernel/smpboot.c
testing/arch/ia64/kernel/smpboot.c
--- linux-2.6.31/arch/ia64/kernel/smpboot.c	2009-09-09 15:13:59.000000000 -=
0700
+++ testing/arch/ia64/kernel/smpboot.c	2009-12-02 21:56:56.000000000 -0800
@@ -504,7 +504,7 @@
 	struct create_idle c_idle =3D {
 		.work =3D __WORK_INITIALIZER(c_idle.work, do_fork_idle),
 		.cpu	=3D cpu,
-		.done	=3D COMPLETION_INITIALIZER(c_idle.done),
+		.done	=3D COMPLETION_INITIALIZER_ONSTACK(c_idle.done),
 	};

  	c_idle.idle =3D get_idle_for_cpu(cpu);
diff -BruN linux-2.6.31/arch/ia64/kernel/stacktrace.c
testing/arch/ia64/kernel/stacktrace.c
--- linux-2.6.31/arch/ia64/kernel/stacktrace.c	1969-12-31
16:00:00.000000000 -0800
+++ testing/arch/ia64/kernel/stacktrace.c	2009-12-03 12:33:55.000000000 -08=
00
@@ -0,0 +1,24 @@
+/*
+ * arch/x86_64/kernel/stacktrace.c
+ *
+ * Stack trace management functions
+ *
+ *  Copyright (C) 2006 Red Hat, Inc., Ingo Molnar <mingo@redhat.com>
+ */
+#include <linux/sched.h>
+#include <linux/stacktrace.h>
+#include <linux/module.h>
+#include <asm/stacktrace.h>
+
+/*
+ * Save stack-backtrace addresses into a stack_trace buffer.
+ */
+void save_stack_trace(struct stack_trace *trace)
+{
+}
+EXPORT_SYMBOL(save_stack_trace);
+
+void __ia64_save_stack_nonlocal(struct stack_trace *trace)
+{
+}
+EXPORT_SYMBOL(__ia64_save_stack_nonlocal);
diff -BruN linux-2.6.31/arch/ia64/kernel/time.c testing/arch/ia64/kernel/ti=
me.c
--- linux-2.6.31/arch/ia64/kernel/time.c	2009-09-09 15:13:59.000000000 -070=
0
+++ testing/arch/ia64/kernel/time.c	2009-12-03 11:52:41.000000000 -0800
@@ -210,8 +210,8 @@
 		/*
 		 * Allow IPIs to interrupt the timer loop.
 		 */
-		local_irq_enable();
-		local_irq_disable();
+		raw_local_irq_enable();
+		raw_local_irq_disable();
 	}

 skip_process_time_accounting:
diff -BruN linux-2.6.31/include/linux/lockdep.h testing/include/linux/lockd=
ep.h
--- linux-2.6.31/include/linux/lockdep.h	2009-09-09 15:13:59.000000000 -070=
0
+++ testing/include/linux/lockdep.h	2009-12-02 21:57:38.000000000 -0800
@@ -162,7 +162,7 @@
 	u64				chain_key;
 };

-#define MAX_LOCKDEP_KEYS_BITS		13
+#define MAX_LOCKDEP_KEYS_BITS		10
 /*
  * Subtract one because we offset hlock->class_idx by 1 in order
  * to make 0 mean no class. This avoids overflowing the class_idx

--0016368e26de018cbc0479e2102b
Content-Type: application/octet-stream; 
	name="ia64-lockdep-linux-2.6.31.patch"
Content-Disposition: attachment; filename="ia64-lockdep-linux-2.6.31.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_g2sn4dgo0

ZGlmZiAtQnJ1TiBsaW51eC0yLjYuMzEvYXJjaC9pYTY0L2luY2x1ZGUvYXNtL2lycWZsYWdzLmgg
dGVzdGluZy9hcmNoL2lhNjQvaW5jbHVkZS9hc20vaXJxZmxhZ3MuaAotLS0gbGludXgtMi42LjMx
L2FyY2gvaWE2NC9pbmNsdWRlL2FzbS9pcnFmbGFncy5oCTE5NjktMTItMzEgMTY6MDA6MDAuMDAw
MDAwMDAwIC0wODAwCisrKyB0ZXN0aW5nL2FyY2gvaWE2NC9pbmNsdWRlL2FzbS9pcnFmbGFncy5o
CTIwMDktMTItMDMgMTU6NDA6NDUuMDAwMDAwMDAwIC0wODAwCkBAIC0wLDAgKzEsMTAxIEBACisj
aWZuZGVmIF9BU01fSVJRRkxBR1NfSAorI2RlZmluZSBfQVNNX0lSUUZMQUdTX0gKKyNpbmNsdWRl
IDxhc20va3JlZ3MuaD4KKyNpbmNsdWRlIDxhc20vcGFsLmg+CisvKgorICogVGhlIGdyb3VwIGJh
cnJpZXIgaW4gZnJvbnQgb2YgdGhlIHJzbSAmIHNzbSBhcmUgbmVjZXNzYXJ5IHRvIGVuc3VyZQor
ICogdGhhdCBub25lIG9mIHRoZSBwcmV2aW91cyBpbnN0cnVjdGlvbnMgaW4gdGhlIHNhbWUgZ3Jv
dXAgYXJlCisgKiBhZmZlY3RlZCBieSB0aGUgcnNtL3NzbS4KKyAqCisgKiBGb3Igc3BpbmxvY2tz
IGV0YyAKKyAqIC0gY2xlYXJpbmcgcHNyLmkgaXMgaW1wbGljaXRseSBzZXJpYWxpemVkICh2aXNp
YmxlIGJ5IG5leHQgaW5zbikKKyAqIC0gc2V0dGluZyBwc3IuaSByZXF1aXJlcyBkYXRhIHNlcmlh
bGl6YXRpb24KKyAqIC0gd2UgbmVlZCBhIHN0b3AtYml0IGJlZm9yZSByZWFkaW5nIFBTUiBiZWNh
dXNlIHdlIHNvbWV0aW1lcworICogICB3cml0ZSBhIGZsb2F0aW5nLXBvaW50IHJlZ2lzdGVyIHJp
Z2h0IGJlZm9yZSByZWFkaW5nIHRoZSBQU1IKKyAqICAgYW5kIHRoYXQgd3JpdGVzIHRvIFBTUi5t
ZmwKKyAqLworI2RlZmluZSBfX2xvY2FsX2lycV9zYXZlKHgpCQkJXAorZG8gewkJCQkJCVwKKwlp
YTY0X3N0b3AoKTsJCQkJXAorCSh4KSA9IGlhNjRfZ2V0cmVnKF9JQTY0X1JFR19QU1IpOwlcCisJ
aWE2NF9zdG9wKCk7CQkJCVwKKwlpYTY0X3JzbShJQTY0X1BTUl9JKTsJCQlcCit9IHdoaWxlICgw
KQorCisjZGVmaW5lIF9fbG9jYWxfaXJxX2Rpc2FibGUoKQkJCVwKK2RvIHsJCQkJCQlcCisJaWE2
NF9zdG9wKCk7CQkJCVwKKwlpYTY0X3JzbShJQTY0X1BTUl9JKTsJCQlcCit9IHdoaWxlICgwKQor
CisjZGVmaW5lIF9fbG9jYWxfaXJxX3Jlc3RvcmUoeCkJaWE2NF9pbnRyaW5fbG9jYWxfaXJxX3Jl
c3RvcmUoKHgpICYgSUE2NF9QU1JfSSkKKworI2lmZGVmIENPTkZJR19JQTY0X0RFQlVHX0lSUQor
CisgIGV4dGVybiB1bnNpZ25lZCBsb25nIGxhc3RfY2xpX2lwOworCisjIGRlZmluZSBfX3NhdmVf
aXAoKQkJbGFzdF9jbGlfaXAgPSBpYTY0X2dldHJlZyhfSUE2NF9SRUdfSVApCisKKyMgZGVmaW5l
IHJhd19sb2NhbF9pcnFfc2F2ZSh4KQkJCQkJXAorZG8gewkJCQkJCQkJXAorCXVuc2lnbmVkIGxv
bmcgcHNyOwkJCQkJXAorCQkJCQkJCQlcCisJX19sb2NhbF9pcnFfc2F2ZShwc3IpOwkJCQkJXAor
CWlmIChwc3IgJiBJQTY0X1BTUl9JKQkJCQkJXAorCQlfX3NhdmVfaXAoKTsJCQkJCVwKKwkoeCkg
PSBwc3I7CQkJCQkJXAorfSB3aGlsZSAoMCkKKworIyBkZWZpbmUgcmF3X2xvY2FsX2lycV9kaXNh
YmxlKCkJZG8geyB1bnNpZ25lZCBsb25nIHg7IHJhd19sb2NhbF9pcnFfc2F2ZSh4KTsgfSB3aGls
ZSAoMCkKKworIyBkZWZpbmUgcmF3X2xvY2FsX2lycV9yZXN0b3JlKHgpCQkJCQlcCitkbyB7CQkJ
CQkJCQlcCisJdW5zaWduZWQgbG9uZyBvbGRfcHNyLCBwc3IgPSAoeCk7CQkJXAorCQkJCQkJCQlc
CisJbG9jYWxfc2F2ZV9mbGFncyhvbGRfcHNyKTsJCQkJXAorCV9fbG9jYWxfaXJxX3Jlc3RvcmUo
cHNyKTsJCQkJXAorCWlmICgob2xkX3BzciAmIElBNjRfUFNSX0kpICYmICEocHNyICYgSUE2NF9Q
U1JfSSkpCVwKKwkJX19zYXZlX2lwKCk7CQkJCQlcCit9IHdoaWxlICgwKQorCisjZWxzZSAvKiAh
Q09ORklHX0lBNjRfREVCVUdfSVJRICovCisjIGRlZmluZSByYXdfbG9jYWxfaXJxX3NhdmUoeCkJ
X19sb2NhbF9pcnFfc2F2ZSh4KQorIyBkZWZpbmUgcmF3X2xvY2FsX2lycV9kaXNhYmxlKCkJX19s
b2NhbF9pcnFfZGlzYWJsZSgpCisjIGRlZmluZSByYXdfbG9jYWxfaXJxX3Jlc3RvcmUoeCkJX19s
b2NhbF9pcnFfcmVzdG9yZSh4KQorI2VuZGlmIC8qICFDT05GSUdfSUE2NF9ERUJVR19JUlEgKi8K
KworI2RlZmluZSByYXdfbG9jYWxfaXJxX2VuYWJsZSgpCSh7IGlhNjRfc3RvcCgpOyBpYTY0X3Nz
bShJQTY0X1BTUl9JKTsgaWE2NF9zcmx6X2QoKTsgfSkKKyNkZWZpbmUgcmF3X2xvY2FsX3NhdmVf
ZmxhZ3MoZmxhZ3MpCSh7IGlhNjRfc3RvcCgpOyAoZmxhZ3MpID0gaWE2NF9nZXRyZWcoX0lBNjRf
UkVHX1BTUik7IH0pCisKKyNkZWZpbmUgcmF3X2lycXNfZGlzYWJsZWQoKQkJCQlcCisoewkJCQkJ
CVwKKwl1bnNpZ25lZCBsb25nIF9faWE2NF9pZF9mbGFnczsJCVwKKwlyYXdfbG9jYWxfc2F2ZV9m
bGFncyhfX2lhNjRfaWRfZmxhZ3MpOwlcCisJKF9faWE2NF9pZF9mbGFncyAmIElBNjRfUFNSX0kp
ID09IDA7CVwKK30pCisKKyNkZWZpbmUgcmF3X3NhZmVfaGFsdCgpICAgICAgICAgaWE2NF9wYWxf
aGFsdF9saWdodCgpICAgIC8qIFBBTF9IQUxUX0xJR0hUICovCisjZGVmaW5lIHJhd19pcnFzX2Rp
c2FibGVkX2ZsYWdzKGZsYWdzKQlcCisoewkJCQkJCVwKKwkoaW50KSgoZmxhZ3MpICYgSUE2NF9Q
U1JfSSkgPT0gMDsJXAorfSkKKwkKKyNpZmRlZiBDT05GSUdfVFJBQ0VfSVJRRkxBR1MKKyNkZWZp
bmUgVFJBQ0VfSVJRU19PTiBici5jYWxsLnNwdGsubWFueSBiMD10cmFjZV9oYXJkaXJxc19vbgor
I2RlZmluZSBUUkFDRV9JUlFTX09GRiBici5jYWxsLnNwdGsubWFueSBiMD10cmFjZV9oYXJkaXJx
c19vZmYKKyNlbHNlCisjZGVmaW5lIFRSQUNFX0lSUVNfT04KKyNkZWZpbmUgVFJBQ0VfSVJRU19P
RkYKKyNlbmRpZgorCisjZGVmaW5lIEFSQ0hfTE9DS0RFUF9TWVNfRVhJVCBici5jYWxsLnNwdGsu
bWFueSBycD1sb2NrZGVwX3N5c19leGl0CisKKyNpZmRlZiBDT05GSUdfREVCVUdfTE9DS19BTExP
QworI2RlZmluZSBMT0NLREVQX1NZU19FWElUCUFSQ0hfTE9DS0RFUF9TWVNfRVhJVAorI2Vsc2UK
KyNkZWZpbmUgTE9DS0RFUF9TWVNfRVhJVAorI2VuZGlmCisKKyNlbmRpZgorCisKZGlmZiAtQnJ1
TiBsaW51eC0yLjYuMzEvYXJjaC9pYTY0L2luY2x1ZGUvYXNtL3BhZ2UuaCB0ZXN0aW5nL2FyY2gv
aWE2NC9pbmNsdWRlL2FzbS9wYWdlLmgKLS0tIGxpbnV4LTIuNi4zMS9hcmNoL2lhNjQvaW5jbHVk
ZS9hc20vcGFnZS5oCTIwMDktMDktMDkgMTU6MTM6NTkuMDAwMDAwMDAwIC0wNzAwCisrKyB0ZXN0
aW5nL2FyY2gvaWE2NC9pbmNsdWRlL2FzbS9wYWdlLmgJMjAwOS0xMi0wMyAxMjowMTo1MC4wMDAw
MDAwMDAgLTA4MDAKQEAgLTQxLDcgKzQxLDcgQEAKICNkZWZpbmUgUEFHRV9TSVpFCQkoX19JQTY0
X1VMX0NPTlNUKDEpIDw8IFBBR0VfU0hJRlQpCiAjZGVmaW5lIFBBR0VfTUFTSwkJKH4oUEFHRV9T
SVpFIC0gMSkpCiAKLSNkZWZpbmUgUEVSQ1BVX1BBR0VfU0hJRlQJMTYJLyogbG9nMigpIG9mIG1h
eC4gc2l6ZSBvZiBwZXItQ1BVIGFyZWEgKi8KKyNkZWZpbmUgUEVSQ1BVX1BBR0VfU0hJRlQJMjAJ
LyoyMCBsb2cyKCkgb2YgbWF4LiBzaXplIG9mIHBlci1DUFUgYXJlYSAqLwogI2RlZmluZSBQRVJD
UFVfUEFHRV9TSVpFCShfX0lBNjRfVUxfQ09OU1QoMSkgPDwgUEVSQ1BVX1BBR0VfU0hJRlQpCiAK
IApkaWZmIC1CcnVOIGxpbnV4LTIuNi4zMS9hcmNoL2lhNjQvaW5jbHVkZS9hc20vcndzZW0uaCB0
ZXN0aW5nL2FyY2gvaWE2NC9pbmNsdWRlL2FzbS9yd3NlbS5oCi0tLSBsaW51eC0yLjYuMzEvYXJj
aC9pYTY0L2luY2x1ZGUvYXNtL3J3c2VtLmgJMjAwOS0wOS0wOSAxNToxMzo1OS4wMDAwMDAwMDAg
LTA3MDAKKysrIHRlc3RpbmcvYXJjaC9pYTY0L2luY2x1ZGUvYXNtL3J3c2VtLmgJMjAwOS0xMi0w
MyAxMTozOToyNy4wMDAwMDAwMDAgLTA4MDAKQEAgLTM3LDYgKzM3LDkgQEAKIAlzaWduZWQgbG9u
ZwkJY291bnQ7CiAJc3BpbmxvY2tfdAkJd2FpdF9sb2NrOwogCXN0cnVjdCBsaXN0X2hlYWQJd2Fp
dF9saXN0OworI2lmZGVmIENPTkZJR19ERUJVR19MT0NLX0FMTE9DCisJc3RydWN0IGxvY2tkZXBf
bWFwIGRlcF9tYXA7CisjZW5kaWYgCiB9OwogCiAjZGVmaW5lIFJXU0VNX1VOTE9DS0VEX1ZBTFVF
CQlfX0lBNjRfVUxfQ09OU1QoMHgwMDAwMDAwMDAwMDAwMDAwKQpAQCAtNDYsOSArNDksMTUgQEAK
ICNkZWZpbmUgUldTRU1fQUNUSVZFX1JFQURfQklBUwkJUldTRU1fQUNUSVZFX0JJQVMKICNkZWZp
bmUgUldTRU1fQUNUSVZFX1dSSVRFX0JJQVMJCShSV1NFTV9XQUlUSU5HX0JJQVMgKyBSV1NFTV9B
Q1RJVkVfQklBUykKIAorI2lmZGVmIENPTkZJR19ERUJVR19MT0NLX0FMTE9DCisjIGRlZmluZSBf
X1JXU0VNX0RFUF9NQVBfSU5JVChsb2NrbmFtZSkgLCAuZGVwX21hcCA9IHsgLm5hbWUgPSAjbG9j
a25hbWUgfQorI2Vsc2UKKyMgZGVmaW5lIF9fUldTRU1fREVQX01BUF9JTklUKGxvY2tuYW1lKQor
I2VuZGlmCisKICNkZWZpbmUgX19SV1NFTV9JTklUSUFMSVpFUihuYW1lKSBcCiAJeyBSV1NFTV9V
TkxPQ0tFRF9WQUxVRSwgU1BJTl9MT0NLX1VOTE9DS0VELCBcCi0JICBMSVNUX0hFQURfSU5JVCgo
bmFtZSkud2FpdF9saXN0KSB9CisJICBMSVNUX0hFQURfSU5JVCgobmFtZSkud2FpdF9saXN0KSBf
X1JXU0VNX0RFUF9NQVBfSU5JVChuYW1lKX0KIAogI2RlZmluZSBERUNMQVJFX1JXU0VNKG5hbWUp
IFwKIAlzdHJ1Y3Qgcndfc2VtYXBob3JlIG5hbWUgPSBfX1JXU0VNX0lOSVRJQUxJWkVSKG5hbWUp
CkBAIC01OCwxMyArNjcsMTUgQEAKIGV4dGVybiBzdHJ1Y3Qgcndfc2VtYXBob3JlICpyd3NlbV93
YWtlKHN0cnVjdCByd19zZW1hcGhvcmUgKnNlbSk7CiBleHRlcm4gc3RydWN0IHJ3X3NlbWFwaG9y
ZSAqcndzZW1fZG93bmdyYWRlX3dha2Uoc3RydWN0IHJ3X3NlbWFwaG9yZSAqc2VtKTsKIAotc3Rh
dGljIGlubGluZSB2b2lkCi1pbml0X3J3c2VtIChzdHJ1Y3Qgcndfc2VtYXBob3JlICpzZW0pCi17
Ci0Jc2VtLT5jb3VudCA9IFJXU0VNX1VOTE9DS0VEX1ZBTFVFOwotCXNwaW5fbG9ja19pbml0KCZz
ZW0tPndhaXRfbG9jayk7Ci0JSU5JVF9MSVNUX0hFQUQoJnNlbS0+d2FpdF9saXN0KTsKLX0KK2V4
dGVybiB2b2lkIF9faW5pdF9yd3NlbShzdHJ1Y3Qgcndfc2VtYXBob3JlICpzZW0sIGNvbnN0IGNo
YXIgKm5hbWUsCisJCQkgc3RydWN0IGxvY2tfY2xhc3Nfa2V5ICprZXkpOworCisjZGVmaW5lIGlu
aXRfcndzZW0oc2VtKQkJCQkJCVwKK2RvIHsJCQkJCQkJCVwKKwlzdGF0aWMgc3RydWN0IGxvY2tf
Y2xhc3Nfa2V5IF9fa2V5OwkJCVwKKwkJCQkJCQkJXAorCV9faW5pdF9yd3NlbSgoc2VtKSwgI3Nl
bSwgJl9fa2V5KTsJCQlcCit9IHdoaWxlICgwKQogCiAvKgogICogbG9jayBmb3IgcmVhZGluZwpk
aWZmIC1CcnVOIGxpbnV4LTIuNi4zMS9hcmNoL2lhNjQvaW5jbHVkZS9hc20vc3RhY2t0cmFjZS5o
IHRlc3RpbmcvYXJjaC9pYTY0L2luY2x1ZGUvYXNtL3N0YWNrdHJhY2UuaAotLS0gbGludXgtMi42
LjMxL2FyY2gvaWE2NC9pbmNsdWRlL2FzbS9zdGFja3RyYWNlLmgJMTk2OS0xMi0zMSAxNjowMDow
MC4wMDAwMDAwMDAgLTA4MDAKKysrIHRlc3RpbmcvYXJjaC9pYTY0L2luY2x1ZGUvYXNtL3N0YWNr
dHJhY2UuaAkyMDA5LTEyLTAzIDEyOjMyOjU4LjAwMDAwMDAwMCAtMDgwMApAQCAtMCwwICsxLDcg
QEAKKyNpZm5kZWYgX0FTTV9TVEFDS1RSQUNFX0gKKyNkZWZpbmUgX0FTTV9TVEFDS1RSQUNFX0gg
MQorCisvKiBHZW5lcmljIHN0YWNrIHRyYWNlciB3aXRoIGNhbGxiYWNrcyAqLworCisKKyNlbmRp
ZgpkaWZmIC1CcnVOIGxpbnV4LTIuNi4zMS9hcmNoL2lhNjQvaW5jbHVkZS9hc20vc3lzdGVtLmgg
dGVzdGluZy9hcmNoL2lhNjQvaW5jbHVkZS9hc20vc3lzdGVtLmgKLS0tIGxpbnV4LTIuNi4zMS9h
cmNoL2lhNjQvaW5jbHVkZS9hc20vc3lzdGVtLmgJMjAwOS0wOS0wOSAxNToxMzo1OS4wMDAwMDAw
MDAgLTA3MDAKKysrIHRlc3RpbmcvYXJjaC9pYTY0L2luY2x1ZGUvYXNtL3N5c3RlbS5oCTIwMDkt
MTItMDIgMjE6NTY6NTYuMDAwMDAwMDAwIC0wODAwCkBAIC0xMDcsODggKzEwNyw2IEBACiAgKi8K
ICNkZWZpbmUgc2V0X21iKHZhciwgdmFsdWUpCWRvIHsgKHZhcikgPSAodmFsdWUpOyBtYigpOyB9
IHdoaWxlICgwKQogCi0jZGVmaW5lIHNhZmVfaGFsdCgpICAgICAgICAgaWE2NF9wYWxfaGFsdF9s
aWdodCgpICAgIC8qIFBBTF9IQUxUX0xJR0hUICovCi0KLS8qCi0gKiBUaGUgZ3JvdXAgYmFycmll
ciBpbiBmcm9udCBvZiB0aGUgcnNtICYgc3NtIGFyZSBuZWNlc3NhcnkgdG8gZW5zdXJlCi0gKiB0
aGF0IG5vbmUgb2YgdGhlIHByZXZpb3VzIGluc3RydWN0aW9ucyBpbiB0aGUgc2FtZSBncm91cCBh
cmUKLSAqIGFmZmVjdGVkIGJ5IHRoZSByc20vc3NtLgotICovCi0vKiBGb3Igc3BpbmxvY2tzIGV0
YyAqLwotCi0vKgotICogLSBjbGVhcmluZyBwc3IuaSBpcyBpbXBsaWNpdGx5IHNlcmlhbGl6ZWQg
KHZpc2libGUgYnkgbmV4dCBpbnNuKQotICogLSBzZXR0aW5nIHBzci5pIHJlcXVpcmVzIGRhdGEg
c2VyaWFsaXphdGlvbgotICogLSB3ZSBuZWVkIGEgc3RvcC1iaXQgYmVmb3JlIHJlYWRpbmcgUFNS
IGJlY2F1c2Ugd2Ugc29tZXRpbWVzCi0gKiAgIHdyaXRlIGEgZmxvYXRpbmctcG9pbnQgcmVnaXN0
ZXIgcmlnaHQgYmVmb3JlIHJlYWRpbmcgdGhlIFBTUgotICogICBhbmQgdGhhdCB3cml0ZXMgdG8g
UFNSLm1mbAotICovCi0jaWZkZWYgQ09ORklHX1BBUkFWSVJUCi0jZGVmaW5lIF9fbG9jYWxfc2F2
ZV9mbGFncygpCWlhNjRfZ2V0X3Bzcl9pKCkKLSNlbHNlCi0jZGVmaW5lIF9fbG9jYWxfc2F2ZV9m
bGFncygpCWlhNjRfZ2V0cmVnKF9JQTY0X1JFR19QU1IpCi0jZW5kaWYKLQotI2RlZmluZSBfX2xv
Y2FsX2lycV9zYXZlKHgpCQkJXAotZG8gewkJCQkJCVwKLQlpYTY0X3N0b3AoKTsJCQkJXAotCSh4
KSA9IF9fbG9jYWxfc2F2ZV9mbGFncygpOwkJXAotCWlhNjRfc3RvcCgpOwkJCQlcCi0JaWE2NF9y
c20oSUE2NF9QU1JfSSk7CQkJXAotfSB3aGlsZSAoMCkKLQotI2RlZmluZSBfX2xvY2FsX2lycV9k
aXNhYmxlKCkJCQlcCi1kbyB7CQkJCQkJXAotCWlhNjRfc3RvcCgpOwkJCQlcCi0JaWE2NF9yc20o
SUE2NF9QU1JfSSk7CQkJXAotfSB3aGlsZSAoMCkKLQotI2RlZmluZSBfX2xvY2FsX2lycV9yZXN0
b3JlKHgpCWlhNjRfaW50cmluX2xvY2FsX2lycV9yZXN0b3JlKCh4KSAmIElBNjRfUFNSX0kpCi0K
LSNpZmRlZiBDT05GSUdfSUE2NF9ERUJVR19JUlEKLQotICBleHRlcm4gdW5zaWduZWQgbG9uZyBs
YXN0X2NsaV9pcDsKLQotIyBkZWZpbmUgX19zYXZlX2lwKCkJCWxhc3RfY2xpX2lwID0gaWE2NF9n
ZXRyZWcoX0lBNjRfUkVHX0lQKQotCi0jIGRlZmluZSBsb2NhbF9pcnFfc2F2ZSh4KQkJCQkJXAot
ZG8gewkJCQkJCQkJXAotCXVuc2lnbmVkIGxvbmcgX19wc3I7CQkJCQlcCi0JCQkJCQkJCVwKLQlf
X2xvY2FsX2lycV9zYXZlKF9fcHNyKTsJCQkJXAotCWlmIChfX3BzciAmIElBNjRfUFNSX0kpCQkJ
CQlcCi0JCV9fc2F2ZV9pcCgpOwkJCQkJXAotCSh4KSA9IF9fcHNyOwkJCQkJCVwKLX0gd2hpbGUg
KDApCi0KLSMgZGVmaW5lIGxvY2FsX2lycV9kaXNhYmxlKCkJZG8geyB1bnNpZ25lZCBsb25nIF9f
eDsgbG9jYWxfaXJxX3NhdmUoX194KTsgfSB3aGlsZSAoMCkKLQotIyBkZWZpbmUgbG9jYWxfaXJx
X3Jlc3RvcmUoeCkJCQkJCVwKLWRvIHsJCQkJCQkJCVwKLQl1bnNpZ25lZCBsb25nIF9fb2xkX3Bz
ciwgX19wc3IgPSAoeCk7CQkJXAotCQkJCQkJCQlcCi0JbG9jYWxfc2F2ZV9mbGFncyhfX29sZF9w
c3IpOwkJCQlcCi0JX19sb2NhbF9pcnFfcmVzdG9yZShfX3Bzcik7CQkJCVwKLQlpZiAoKF9fb2xk
X3BzciAmIElBNjRfUFNSX0kpICYmICEoX19wc3IgJiBJQTY0X1BTUl9JKSkJXAotCQlfX3NhdmVf
aXAoKTsJCQkJCVwKLX0gd2hpbGUgKDApCi0KLSNlbHNlIC8qICFDT05GSUdfSUE2NF9ERUJVR19J
UlEgKi8KLSMgZGVmaW5lIGxvY2FsX2lycV9zYXZlKHgpCV9fbG9jYWxfaXJxX3NhdmUoeCkKLSMg
ZGVmaW5lIGxvY2FsX2lycV9kaXNhYmxlKCkJX19sb2NhbF9pcnFfZGlzYWJsZSgpCi0jIGRlZmlu
ZSBsb2NhbF9pcnFfcmVzdG9yZSh4KQlfX2xvY2FsX2lycV9yZXN0b3JlKHgpCi0jZW5kaWYgLyog
IUNPTkZJR19JQTY0X0RFQlVHX0lSUSAqLwotCi0jZGVmaW5lIGxvY2FsX2lycV9lbmFibGUoKQko
eyBpYTY0X3N0b3AoKTsgaWE2NF9zc20oSUE2NF9QU1JfSSk7IGlhNjRfc3Jsel9kKCk7IH0pCi0j
ZGVmaW5lIGxvY2FsX3NhdmVfZmxhZ3MoZmxhZ3MpCSh7IGlhNjRfc3RvcCgpOyAoZmxhZ3MpID0g
X19sb2NhbF9zYXZlX2ZsYWdzKCk7IH0pCi0KLSNkZWZpbmUgaXJxc19kaXNhYmxlZCgpCQkJCVwK
LSh7CQkJCQkJXAotCXVuc2lnbmVkIGxvbmcgX19pYTY0X2lkX2ZsYWdzOwkJXAotCWxvY2FsX3Nh
dmVfZmxhZ3MoX19pYTY0X2lkX2ZsYWdzKTsJXAotCShfX2lhNjRfaWRfZmxhZ3MgJiBJQTY0X1BT
Ul9JKSA9PSAwOwlcCi19KQotCiAjaWZkZWYgX19LRVJORUxfXwogCiAjaWZkZWYgQ09ORklHX0lB
MzJfU1VQUE9SVApAQCAtMjc0LDcgKzE5Miw3IEBACiAjZGVmaW5lIF9fQVJDSF9XQU5UX1VOTE9D
S0VEX0NUWFNXCiAjZGVmaW5lIEFSQ0hfSEFTX1BSRUZFVENIX1NXSVRDSF9TVEFDSwogI2RlZmlu
ZSBpYTY0X3BsYXRmb3JtX2lzKHgpIChzdHJjbXAoeCwgcGxhdGZvcm1fbmFtZSkgPT0gMCkKLQor
I2luY2x1ZGUgPGxpbnV4L2lycWZsYWdzLmg+CiB2b2lkIGNwdV9pZGxlX3dhaXQodm9pZCk7CiAK
ICNkZWZpbmUgYXJjaF9hbGlnbl9zdGFjayh4KSAoeCkKZGlmZiAtQnJ1TiBsaW51eC0yLjYuMzEv
YXJjaC9pYTY0L0tjb25maWcgdGVzdGluZy9hcmNoL2lhNjQvS2NvbmZpZwotLS0gbGludXgtMi42
LjMxL2FyY2gvaWE2NC9LY29uZmlnCTIwMDktMDktMDkgMTU6MTM6NTkuMDAwMDAwMDAwIC0wNzAw
CisrKyB0ZXN0aW5nL2FyY2gvaWE2NC9LY29uZmlnCTIwMDktMTItMDMgMTE6NDM6MzguMDAwMDAw
MDAwIC0wODAwCkBAIC0xNDMsNiArMTQzLDEyIEBACiAKIGVuZGlmCiAKK2NvbmZpZyBMT0NLREVQ
X1NVUFBPUlQKKwlkZWZfYm9vbCB5CisKK2NvbmZpZyBTVEFDS1RSQUNFX1NVUFBPUlQKKwlkZWZf
Ym9vbCB5CisKIGNob2ljZQogCXByb21wdCAiU3lzdGVtIHR5cGUiCiAJZGVmYXVsdCBJQTY0X0dF
TkVSSUMKZGlmZiAtQnJ1TiBsaW51eC0yLjYuMzEvYXJjaC9pYTY0L0tjb25maWcuZGVidWcgdGVz
dGluZy9hcmNoL2lhNjQvS2NvbmZpZy5kZWJ1ZwotLS0gbGludXgtMi42LjMxL2FyY2gvaWE2NC9L
Y29uZmlnLmRlYnVnCTIwMDktMDktMDkgMTU6MTM6NTkuMDAwMDAwMDAwIC0wNzAwCisrKyB0ZXN0
aW5nL2FyY2gvaWE2NC9LY29uZmlnLmRlYnVnCTIwMDktMTItMDMgMTE6NDQ6MTYuMDAwMDAwMDAw
IC0wODAwCkBAIC0yLDYgKzIsOSBAQAogCiBzb3VyY2UgImxpYi9LY29uZmlnLmRlYnVnIgogCitj
b25maWcgVFJBQ0VfSVJRRkxBR1NfU1VQUE9SVAorCWRlZl9ib29sIHkKKwogY2hvaWNlCiAJcHJv
bXB0ICJQaHlzaWNhbCBtZW1vcnkgZ3JhbnVsYXJpdHkiCiAJZGVmYXVsdCBJQTY0X0dSQU5VTEVf
NjRNQgpkaWZmIC1CcnVOIGxpbnV4LTIuNi4zMS9hcmNoL2lhNjQva2VybmVsL2VudHJ5LlMgdGVz
dGluZy9hcmNoL2lhNjQva2VybmVsL2VudHJ5LlMKLS0tIGxpbnV4LTIuNi4zMS9hcmNoL2lhNjQv
a2VybmVsL2VudHJ5LlMJMjAwOS0wOS0wOSAxNToxMzo1OS4wMDAwMDAwMDAgLTA3MDAKKysrIHRl
c3RpbmcvYXJjaC9pYTY0L2tlcm5lbC9lbnRyeS5TCTIwMDktMTItMDMgMTI6NTU6NTMuMDAwMDAw
MDAwIC0wODAwCkBAIC00OCw2ICs0OCw3IEBACiAjaW5jbHVkZSA8YXNtL3RocmVhZF9pbmZvLmg+
CiAjaW5jbHVkZSA8YXNtL3VuaXN0ZC5oPgogI2luY2x1ZGUgPGFzbS9mdHJhY2UuaD4KKyNpbmNs
dWRlIDxhc20vaXJxZmxhZ3MuaD4KIAogI2luY2x1ZGUgIm1pbnN0YXRlLmgiCiAKQEAgLTg5Nyw2
ICs4OTksMTEgQEAKIAljbXAuZXEgcDYscDA9cjIxLHIwCQkvLyBwNiA8LSBwVVN0ayB8fCAocHJl
ZW1wdF9jb3VudCA9PSAwKQogI2Vsc2UKIAlSU01fUFNSX0kocFVTdGssIHIxNywgcjMxKQorI2lm
IDAgLy9Ub2RvOiBmaXggbG9jayBoZWxkIHdoZW4gcmV0dXJuaW5nIHRvIHVzZXIgc3BhY2UKKwk7
OworCUxPQ0tERVBfU1lTX0VYSVQKKwk7OworI2VuZGlmCiAJY21wLmVxIHAwLHBMdlN5cz1yMCxy
MAkJLy8gcEx2U3lzPTA6IGxlYXZlIGZyb20ga2VybmVsCiAocFVTdGspCWNtcC5lcS51bmMgcDYs
cDA9cjAscjAJCS8vIHA2IDwtIHBVU3RrCiAjZW5kaWYKZGlmZiAtQnJ1TiBsaW51eC0yLjYuMzEv
YXJjaC9pYTY0L2tlcm5lbC9pdnQuUyB0ZXN0aW5nL2FyY2gvaWE2NC9rZXJuZWwvaXZ0LlMKLS0t
IGxpbnV4LTIuNi4zMS9hcmNoL2lhNjQva2VybmVsL2l2dC5TCTIwMDktMDktMDkgMTU6MTM6NTku
MDAwMDAwMDAwIC0wNzAwCisrKyB0ZXN0aW5nL2FyY2gvaWE2NC9rZXJuZWwvaXZ0LlMJMjAwOS0x
Mi0wMyAxMTo1MDo0MC4wMDAwMDAwMDAgLTA4MDAKQEAgLTg1NSw2ICs4NTUsMTEgQEAKIAltb3Yg
cnA9cjMJCQkJLy8gSTAgICBzZXQgdGhlIHJlYWwgcmV0dXJuIGFkZHIKIChwMTApCWJyLmNvbmQu
c3BudC5tYW55IGlhNjRfcmV0X2Zyb21fc3lzY2FsbAkvLyBCICAgIHJldHVybiBpZiBiYWQgY2Fs
bC1mcmFtZSBvciByMTUgaXMgYSBOYVQKIAorI2lmZGVmIFRSQUNFX0lSUUZMQUdTX1NVUFBPUlQK
Kwk7OworKHAxNSkJYnIuY2FsbC5zcHRrLm1hbnkgcnA9dHJhY2VfaGFyZGlycXNfb24KKwk7Owor
I2VuZGlmCiAJU1NNX1BTUl9JKHAxNSwgcDE1LCByMTYpCQkvLyBNMiAgIHJlc3RvcmUgcHNyLmkK
IChwMTQpCWJyLmNhbGwuc3B0ay5tYW55IGI2PWI2CQkJLy8gQiAgICBpbnZva2Ugc3lzY2FsbC1o
YW5ka2VyIChpZ25vcmUgcmV0dXJuIGFkZHIpCiAJYnIuY29uZC5zcG50Lm1hbnkgaWE2NF90cmFj
ZV9zeXNjYWxsCS8vIEIJZG8gc3lzY2FsbC10cmFjaW5nIHRoaW5nYW1hZ2ljCkBAIC0xNTU1LDYg
KzE1NjAsMTEgQEAKIAlNT1ZfRlJPTV9JU1Iob3V0MSkKIAlTU01fUFNSX0lDX0FORF9ERUZBVUxU
X0JJVFNfQU5EX1NSTFpfSShyMTQsIHIzKQogCWFkZHMgcjM9OCxyMgkJCQkvLyBzZXQgdXAgc2Vj
b25kIGJhc2UgcG9pbnRlcgorI2lmZGVmIFRSQUNFX0lSUUZMQUdTX1NVUFBPUlQKKwk7OworKHAx
NSkJYnIuY2FsbC5zcHRrLm1hbnkgcnA9dHJhY2VfaGFyZGlycXNfb24KKwk7OworI2VuZGlmCiAJ
U1NNX1BTUl9JKHAxNSwgcDE1LCByMTQpCQkvLyByZXN0b3JlIHBzci5pCiAJbW92bCByMTQ9aWE2
NF9sZWF2ZV9rZXJuZWwKIAk7OwpAQCAtMTU4Miw2ICsxNTkyLDExIEBACiAKIAlTU01fUFNSX0lD
X0FORF9ERUZBVUxUX0JJVFNfQU5EX1NSTFpfSShyMTUsIHIyNCkKIAkJCQkJLy8gZ3VhcmFudGVl
IHRoYXQgaW50ZXJydXB0aW9uIGNvbGxlY3Rpb24gaXMgb24KKyNpZmRlZiBUUkFDRV9JUlFGTEFH
U19TVVBQT1JUCisJOzsKKyhwMTUpCWJyLmNhbGwuc3B0ay5tYW55IHJwPXRyYWNlX2hhcmRpcnFz
X29uCisJOzsKKyNlbmRpZgogCVNTTV9QU1JfSShwMTUsIHAxNSwgcjE1KQkvLyByZXN0b3JlIHBz
ci5pCiAJbW92bCByMTU9aWE2NF9sZWF2ZV9rZXJuZWwKIAk7OwpAQCAtMTYzMCw2ICsxNjQ1LDEx
IEBACiAKIAlTU01fUFNSX0lDX0FORF9ERUZBVUxUX0JJVFNfQU5EX1NSTFpfSShyMywgcjI0KQog
CQkJCQkJLy8gZ3VhcmFudGVlIHRoYXQgaW50ZXJydXB0aW9uIGNvbGxlY3Rpb24gaXMgb24KKyNp
ZmRlZiBUUkFDRV9JUlFGTEFHU19TVVBQT1JUCisJOzsKKyhwMTUpCWJyLmNhbGwuc3B0ay5tYW55
IHJwPXRyYWNlX2hhcmRpcnFzX29uCisJOzsKKyNlbmRpZgogCVNTTV9QU1JfSShwMTUsIHAxNSwg
cjMpCQkJLy8gcmVzdG9yZSBwc3IuaQogCWFkZHMgcjM9OCxyMgkJCQkvLyBzZXQgdXAgc2Vjb25k
IGJhc2UgcG9pbnRlcgogCTs7CkBAIC0xNjY1LDYgKzE2ODUsMTEgQEAKIAkJCQkJCS8vIGd1YXJh
bnRlZSB0aGF0IGludGVycnVwdGlvbiBjb2xsZWN0aW9uIGlzIG9uCiAJbW92IG91dDA9cjE1CiAJ
OzsKKyNpZmRlZiBUUkFDRV9JUlFGTEFHU19TVVBQT1JUCisJOzsKKyhwMTUpCWJyLmNhbGwuc3B0
ay5tYW55IHJwPXRyYWNlX2hhcmRpcnFzX29uCisJOzsKKyNlbmRpZgogCVNTTV9QU1JfSShwMTUs
IHAxNSwgcjMpCQkJLy8gcmVzdG9yZSBwc3IuaQogCWFkZHMgcjM9OCxyMgkJCQkvLyBzZXQgdXAg
c2Vjb25kIGJhc2UgcG9pbnRlciBmb3IgU0FWRV9SRVNUCiAJOzsKQEAgLTE3MzMsNyArMTc1OCwx
MSBAQAogCU1PVl9GUk9NX0lTUihyMTQpCiAJU1NNX1BTUl9JQ19BTkRfREVGQVVMVF9CSVRTX0FO
RF9TUkxaX0kocjMsIHIyNCkKIAkJCQkvLyBndWFyYW50ZWUgdGhhdCBpbnRlcnJ1cHRpb24gY29s
bGVjdGlvbiBpcyBvbgorI2lmZGVmIFRSQUNFX0lSUUZMQUdTX1NVUFBPUlQKIAk7OworKHAxNSkJ
YnIuY2FsbC5zcHRrLm1hbnkgcnA9dHJhY2VfaGFyZGlycXNfb24KKwk7OworI2VuZGlmCiAJU1NN
X1BTUl9JKHAxNSwgcDE1LCByMykKIAlhZGRzIHIzPTgscjIJCS8vIEJhc2UgcG9pbnRlciBmb3Ig
U0FWRV9SRVNUCiAJOzsKZGlmZiAtQnJ1TiBsaW51eC0yLjYuMzEvYXJjaC9pYTY0L2tlcm5lbC9N
YWtlZmlsZSB0ZXN0aW5nL2FyY2gvaWE2NC9rZXJuZWwvTWFrZWZpbGUKLS0tIGxpbnV4LTIuNi4z
MS9hcmNoL2lhNjQva2VybmVsL01ha2VmaWxlCTIwMDktMDktMDkgMTU6MTM6NTkuMDAwMDAwMDAw
IC0wNzAwCisrKyB0ZXN0aW5nL2FyY2gvaWE2NC9rZXJuZWwvTWFrZWZpbGUJMjAwOS0xMi0wMiAy
MTo1Njo1Ni4wMDAwMDAwMDAgLTA4MDAKQEAgLTQwLDYgKzQwLDcgQEAKIG9iai0kKENPTkZJR19Q
Q0lfTVNJKQkJKz0gbXNpX2lhNjQubwogbWNhX3JlY292ZXJ5LXkJCQkrPSBtY2FfZHJ2Lm8gbWNh
X2Rydl9hc20ubwogb2JqLSQoQ09ORklHX0lBNjRfTUNfRVJSX0lOSkVDVCkrPSBlcnJfaW5qZWN0
Lm8KK29iai0kKENPTkZJR19TVEFDS1RSQUNFKQkrPSBzdGFja3RyYWNlLm8KIAogb2JqLSQoQ09O
RklHX1BBUkFWSVJUKQkJKz0gcGFyYXZpcnQubyBwYXJhdmlydGVudHJ5Lm8gXAogCQkJCSAgIHBh
cmF2aXJ0X3BhdGNoLm8KZGlmZiAtQnJ1TiBsaW51eC0yLjYuMzEvYXJjaC9pYTY0L2tlcm5lbC9w
cm9jZXNzLmMgdGVzdGluZy9hcmNoL2lhNjQva2VybmVsL3Byb2Nlc3MuYwotLS0gbGludXgtMi42
LjMxL2FyY2gvaWE2NC9rZXJuZWwvcHJvY2Vzcy5jCTIwMDktMDktMDkgMTU6MTM6NTkuMDAwMDAw
MDAwIC0wNzAwCisrKyB0ZXN0aW5nL2FyY2gvaWE2NC9rZXJuZWwvcHJvY2Vzcy5jCTIwMDktMTIt
MDMgMTE6NTE6MjguMDAwMDAwMDAwIC0wODAwCkBAIC0yMjUsMTQgKzIyNSwxNCBAQAogdm9pZAog
ZGVmYXVsdF9pZGxlICh2b2lkKQogewotCWxvY2FsX2lycV9lbmFibGUoKTsKKwlyYXdfbG9jYWxf
aXJxX2VuYWJsZSgpOwogCXdoaWxlICghbmVlZF9yZXNjaGVkKCkpIHsKIAkJaWYgKGNhbl9kb19w
YWxfaGFsdCkgewotCQkJbG9jYWxfaXJxX2Rpc2FibGUoKTsKKwkJCXJhd19sb2NhbF9pcnFfZGlz
YWJsZSgpOwogCQkJaWYgKCFuZWVkX3Jlc2NoZWQoKSkgewogCQkJCXNhZmVfaGFsdCgpOwogCQkJ
fQotCQkJbG9jYWxfaXJxX2VuYWJsZSgpOworCQkJcmF3X2xvY2FsX2lycV9lbmFibGUoKTsKIAkJ
fSBlbHNlCiAJCQljcHVfcmVsYXgoKTsKIAl9CmRpZmYgLUJydU4gbGludXgtMi42LjMxL2FyY2gv
aWE2NC9rZXJuZWwvc2V0dXAuYyB0ZXN0aW5nL2FyY2gvaWE2NC9rZXJuZWwvc2V0dXAuYwotLS0g
bGludXgtMi42LjMxL2FyY2gvaWE2NC9rZXJuZWwvc2V0dXAuYwkyMDA5LTA5LTA5IDE1OjEzOjU5
LjAwMDAwMDAwMCAtMDcwMAorKysgdGVzdGluZy9hcmNoL2lhNjQva2VybmVsL3NldHVwLmMJMjAw
OS0xMi0wMyAyMzoxNDo1Ni4wMDAwMDAwMDAgLTA4MDAKQEAgLTEwMjEsNyArMTAyMSwxMSBAQAog
CUJVR19PTihjdXJyZW50LT5tbSk7CiAKIAlpYTY0X21tdV9pbml0KGlhNjRfaW12YShjcHVfZGF0
YSkpOworCisJLyogVGVtcG9yYXJpbHkgc3VwcHJlc3MgbG9ja2RlcCBXQVJOX09OIGlycXMgZGlz
YWJsZWQqLyAKKwlsb2NrZGVwX29mZigpOwogCWlhNjRfbWNhX2NwdV9pbml0KGlhNjRfaW12YShj
cHVfZGF0YSkpOworCWxvY2tkZXBfb24oKTsKIAogI2lmZGVmIENPTkZJR19JQTMyX1NVUFBPUlQK
IAlpYTMyX2NwdV9pbml0KCk7CmRpZmYgLUJydU4gbGludXgtMi42LjMxL2FyY2gvaWE2NC9rZXJu
ZWwvc21wYm9vdC5jIHRlc3RpbmcvYXJjaC9pYTY0L2tlcm5lbC9zbXBib290LmMKLS0tIGxpbnV4
LTIuNi4zMS9hcmNoL2lhNjQva2VybmVsL3NtcGJvb3QuYwkyMDA5LTA5LTA5IDE1OjEzOjU5LjAw
MDAwMDAwMCAtMDcwMAorKysgdGVzdGluZy9hcmNoL2lhNjQva2VybmVsL3NtcGJvb3QuYwkyMDA5
LTEyLTAyIDIxOjU2OjU2LjAwMDAwMDAwMCAtMDgwMApAQCAtNTA0LDcgKzUwNCw3IEBACiAJc3Ry
dWN0IGNyZWF0ZV9pZGxlIGNfaWRsZSA9IHsKIAkJLndvcmsgPSBfX1dPUktfSU5JVElBTElaRVIo
Y19pZGxlLndvcmssIGRvX2ZvcmtfaWRsZSksCiAJCS5jcHUJPSBjcHUsCi0JCS5kb25lCT0gQ09N
UExFVElPTl9JTklUSUFMSVpFUihjX2lkbGUuZG9uZSksCisJCS5kb25lCT0gQ09NUExFVElPTl9J
TklUSUFMSVpFUl9PTlNUQUNLKGNfaWRsZS5kb25lKSwKIAl9OwogCiAgCWNfaWRsZS5pZGxlID0g
Z2V0X2lkbGVfZm9yX2NwdShjcHUpOwpkaWZmIC1CcnVOIGxpbnV4LTIuNi4zMS9hcmNoL2lhNjQv
a2VybmVsL3N0YWNrdHJhY2UuYyB0ZXN0aW5nL2FyY2gvaWE2NC9rZXJuZWwvc3RhY2t0cmFjZS5j
Ci0tLSBsaW51eC0yLjYuMzEvYXJjaC9pYTY0L2tlcm5lbC9zdGFja3RyYWNlLmMJMTk2OS0xMi0z
MSAxNjowMDowMC4wMDAwMDAwMDAgLTA4MDAKKysrIHRlc3RpbmcvYXJjaC9pYTY0L2tlcm5lbC9z
dGFja3RyYWNlLmMJMjAwOS0xMi0wMyAxMjozMzo1NS4wMDAwMDAwMDAgLTA4MDAKQEAgLTAsMCAr
MSwyNCBAQAorLyoKKyAqIGFyY2gveDg2XzY0L2tlcm5lbC9zdGFja3RyYWNlLmMKKyAqCisgKiBT
dGFjayB0cmFjZSBtYW5hZ2VtZW50IGZ1bmN0aW9ucworICoKKyAqICBDb3B5cmlnaHQgKEMpIDIw
MDYgUmVkIEhhdCwgSW5jLiwgSW5nbyBNb2xuYXIgPG1pbmdvQHJlZGhhdC5jb20+CisgKi8KKyNp
bmNsdWRlIDxsaW51eC9zY2hlZC5oPgorI2luY2x1ZGUgPGxpbnV4L3N0YWNrdHJhY2UuaD4KKyNp
bmNsdWRlIDxsaW51eC9tb2R1bGUuaD4KKyNpbmNsdWRlIDxhc20vc3RhY2t0cmFjZS5oPgorCisv
KgorICogU2F2ZSBzdGFjay1iYWNrdHJhY2UgYWRkcmVzc2VzIGludG8gYSBzdGFja190cmFjZSBi
dWZmZXIuCisgKi8KK3ZvaWQgc2F2ZV9zdGFja190cmFjZShzdHJ1Y3Qgc3RhY2tfdHJhY2UgKnRy
YWNlKQoreworfQorRVhQT1JUX1NZTUJPTChzYXZlX3N0YWNrX3RyYWNlKTsKKwordm9pZCBfX2lh
NjRfc2F2ZV9zdGFja19ub25sb2NhbChzdHJ1Y3Qgc3RhY2tfdHJhY2UgKnRyYWNlKQoreworfQor
RVhQT1JUX1NZTUJPTChfX2lhNjRfc2F2ZV9zdGFja19ub25sb2NhbCk7CmRpZmYgLUJydU4gbGlu
dXgtMi42LjMxL2FyY2gvaWE2NC9rZXJuZWwvdGltZS5jIHRlc3RpbmcvYXJjaC9pYTY0L2tlcm5l
bC90aW1lLmMKLS0tIGxpbnV4LTIuNi4zMS9hcmNoL2lhNjQva2VybmVsL3RpbWUuYwkyMDA5LTA5
LTA5IDE1OjEzOjU5LjAwMDAwMDAwMCAtMDcwMAorKysgdGVzdGluZy9hcmNoL2lhNjQva2VybmVs
L3RpbWUuYwkyMDA5LTEyLTAzIDExOjUyOjQxLjAwMDAwMDAwMCAtMDgwMApAQCAtMjEwLDggKzIx
MCw4IEBACiAJCS8qCiAJCSAqIEFsbG93IElQSXMgdG8gaW50ZXJydXB0IHRoZSB0aW1lciBsb29w
LgogCQkgKi8KLQkJbG9jYWxfaXJxX2VuYWJsZSgpOwotCQlsb2NhbF9pcnFfZGlzYWJsZSgpOwor
CQlyYXdfbG9jYWxfaXJxX2VuYWJsZSgpOworCQlyYXdfbG9jYWxfaXJxX2Rpc2FibGUoKTsKIAl9
CiAKIHNraXBfcHJvY2Vzc190aW1lX2FjY291bnRpbmc6CmRpZmYgLUJydU4gbGludXgtMi42LjMx
L2luY2x1ZGUvbGludXgvbG9ja2RlcC5oIHRlc3RpbmcvaW5jbHVkZS9saW51eC9sb2NrZGVwLmgK
LS0tIGxpbnV4LTIuNi4zMS9pbmNsdWRlL2xpbnV4L2xvY2tkZXAuaAkyMDA5LTA5LTA5IDE1OjEz
OjU5LjAwMDAwMDAwMCAtMDcwMAorKysgdGVzdGluZy9pbmNsdWRlL2xpbnV4L2xvY2tkZXAuaAky
MDA5LTEyLTAyIDIxOjU3OjM4LjAwMDAwMDAwMCAtMDgwMApAQCAtMTYyLDcgKzE2Miw3IEBACiAJ
dTY0CQkJCWNoYWluX2tleTsKIH07CiAKLSNkZWZpbmUgTUFYX0xPQ0tERVBfS0VZU19CSVRTCQkx
MworI2RlZmluZSBNQVhfTE9DS0RFUF9LRVlTX0JJVFMJCTEwCiAvKgogICogU3VidHJhY3Qgb25l
IGJlY2F1c2Ugd2Ugb2Zmc2V0IGhsb2NrLT5jbGFzc19pZHggYnkgMSBpbiBvcmRlcgogICogdG8g
bWFrZSAwIG1lYW4gbm8gY2xhc3MuIFRoaXMgYXZvaWRzIG92ZXJmbG93aW5nIHRoZSBjbGFzc19p
ZHgK
--0016368e26de018cbc0479e2102b--
