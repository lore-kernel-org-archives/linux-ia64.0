From: Keith Owens <kaos@ocs.com.au>
Date: Fri, 04 Aug 2000 05:46:39 +0000
Subject: [Linux-ia64] [RFC] 2.4.0-test6-pre2 Merge softirq, local_irq_count, local_bh_count
Message-Id: <marc-linux-ia64-105590678205266@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch hits every arch.  It is being cross mailed to every arch
mailing list that has not already confirmed that the patch works.
Please trim replies to the relevant mailing list.

Also please cc: kaos@ocs.com.au on replies, I am not on every list.

---

At the moment (2.4.0-test6-pre2) all architectures have a common
definition for softirq_state, it occupies its own cache line with a lot
of unused padding.  The definitions for local_irq_count and
local_bh_count are all over the place, some architectures use a cache
aligned structure, some use arrays of integers (lets you play cache
ping/pong), some even use atomic_t.

Each arch defines its own set of mapping macros to get to
local_irq_count and local_bh_count.  To add insult to injury, not all
architectures use the mapping macros, there are bits of code scattered
around that use hard coded array lookups which are not optimized for
SMP vs non-SMP.

ftp://ftp.ocs.com.au/pub/2.4.0-test6-pre2-softirq-bh-merge.gz is a
merge of softirq, local_irq_count and local_bh_count into one cache
aligned structure.  The aim was :-

* Put all these fields in a per-cpu cache line.  They are hit by the
  same code paths and are only ever updated from one cpu.  Softirq was
  already cache aligned but the other fields were not, in most cases we
  were using multiple cache lines for this data.  On most archs this
  will save a cache line.  In the worst case we use the same number of
  lines but still get a code cleanup.

* Replace all the explicit references like __local_irq_count[cpu] with
  wrapper macros.  Some arch's had already done this but there was
  quite a bit of crud left.

* Replace multiple arch definitions and export of irq_stat with a
  common one, optimized for SMP or non-SMP.  I know that gcc should do
  this, but proving it will always optimize was too messy so I went for
  the safe case and hand optimized the definitions.  Besides, s390 is
  completely different (the story of my life ;).

* Create a standard definition for the wrappers that can be used by
  almost all architectures.  Only s390 and sparc64 are special cases
  but every arch had its own slightly incompatible definition.

* Add a per-cpu syscall_count, ready for performance reporting on soft
  interrupts as well as hard interrupts.  This field is not being set
  at the moment but will be easy to update once the above patch is
  accepted.

I have updated all architectures, but have only been able to test this
patch on ix86 and IA64.  Could the other arch maintainers try this
patch, it is almost guaranteed to contain some Assembler errors.  If
your arch supports SMP, please try both UP and SMP.

I want to know if the patch works or not on each arch so I can send the
patch to Linus.  So I would appreciate feedback on tests, whether
successful or not.  m68k and super-h have already replied, nobody else
has confirmed one way or the other.

All architectures except s390 and sparc64 use the same definitions, see
include/linux/irq_cpustat.h.  For all but s390, sparc64 and m68k,
please check the Assembler changes, the common code should be fine.

S390    No irq_stat structure, the equivalent fields are stored in
        S390_lowcore.  That moved cpu_data, ipl_device and the SMP info
        area up by 16 bytes.  There was no need for local_bh_count and
        local_irq_count to be atomic.  Please check the changes to
        __LC_ in lowcore.h.  Also the use of lowcore instead of
        irq_stat[NR_CPUS] means that asm-s390/hardirq.h is quite
        different from the other archs, it has its own unique
        definitions for all the wrapper macros.

sparc64 For UP, it uses the common code, local_irq_count is an int in
        irq_stat.  For SMP, local_irq_count is a brlock in cpu_data.
        asm-sparc64/hardirq.h defines a special SMP mapping for
        local_irq_count.

m68k    The change to arch/m68k/atari/ataints.c is a complete guess.
        There were no examples of how to reference SYMBOL+8 from asm in
        atari.

Files patched:

arch/alpha/kernel/alpha_ksyms.c
arch/alpha/kernel/entry.S
arch/alpha/kernel/irq_alpha.c
arch/alpha/kernel/irq_smp.c
arch/alpha/kernel/smp.c
arch/arm/kernel/armksyms.c
arch/arm/kernel/entry-common.S
arch/arm/kernel/irq.c
arch/i386/kernel/entry.S
arch/i386/kernel/i386_ksyms.c
arch/i386/kernel/io_apic.c
arch/i386/kernel/irq.c
arch/i386/kernel/traps.c
arch/ia64/kernel/entry.S
arch/ia64/kernel/ia64_ksyms.c
arch/ia64/kernel/irq.c
arch/m68k/atari/ataints.c
arch/m68k/kernel/entry.S
arch/m68k/kernel/ints.c
arch/m68k/kernel/m68k_ksyms.c
arch/mips/baget/irq.c
arch/mips/dec/irq.c
arch/mips/kernel/entry.S
arch/mips/kernel/irq.c
arch/mips/kernel/mips_ksyms.c
arch/mips/kernel/scall_o32.S
arch/mips/orion/irq.c
arch/mips/sgi/kernel/indy_int.c
arch/mips64/kernel/entry.S
arch/mips64/kernel/scall_64.S
arch/mips64/kernel/scall_o32.S
arch/mips64/sgi-ip22/ip22-int.c
arch/mips64/sgi-ip27/ip27-irq.c
arch/ppc/kernel/entry.S
arch/ppc/kernel/irq.c
arch/ppc/kernel/local_irq.h
arch/ppc/kernel/ppc_ksyms.c
arch/s390/kernel/entry.S
arch/s390/kernel/irq.c
arch/s390/kernel/process.c
arch/s390/kernel/s390io.c
arch/s390/mm/fault.c
arch/sh/kernel/entry.S
arch/sh/kernel/irq.c
arch/sparc/kernel/irq.c
arch/sparc/kernel/rtrap.S
arch/sparc/kernel/sparc_ksyms.c
arch/sparc64/kernel/irq.c
arch/sparc64/kernel/rtrap.S
arch/sparc64/kernel/smp.c
arch/sparc64/kernel/sparc64_ksyms.c
include/asm-alpha/hardirq.h
include/asm-alpha/smp.h
include/asm-alpha/softirq.h
include/asm-arm/hardirq.h
include/asm-i386/hardirq.h
include/asm-ia64/hardirq.h
include/asm-m68k/hardirq.h
include/asm-m68k/softirq.h
include/asm-m68k/system.h
include/asm-mips/hardirq.h
include/asm-mips64/hardirq.h
include/asm-mips64/processor.h
include/asm-mips64/smp.h
include/asm-ppc/hardirq.h
include/asm-ppc/softirq.h
include/asm-s390/hardirq.h
include/asm-s390/irq.h
include/asm-s390/lowcore.h
include/asm-s390/softirq.h
include/asm-sh/hardirq.h
include/asm-sh/softirq.h
include/asm-sparc/hardirq.h
include/asm-sparc/irq.h
include/asm-sparc/softirq.h
include/asm-sparc64/hardirq.h
include/asm-sparc64/smp.h
include/asm-sparc64/softirq.h
include/linux/interrupt.h
include/linux/irq_cpustat.h
kernel/ksyms.c
kernel/sched.c
kernel/softirq.c
net/netsyms.c



