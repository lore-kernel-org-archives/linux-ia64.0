From: richard -rw- weinberger <richard.weinberger@gmail.com>
Date: Mon, 27 Sep 2010 19:48:34 +0000
Subject: Re: [RFC trollpatch 1/1] genirq: Remove the fits all and nothing
Message-Id: <AANLkTin23sJT+OqjDqjyk-Gr5r-GfJ_03Q1WUqNLCzgH@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20100908152036.643594727@linutronix.de>
In-Reply-To: <20100908152036.643594727@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, Christoph Hellwig <hch@infradead.org>, linux-alpha@vger.kernel.org, linux-cris-kernel@axis.com, Haavard Skinnemoen <hskinnemoen@atmel.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Hirokazu Takata <takata@linux-m32r.org>, Greg Ungerer <gerg@uclinux.org>, Jeff Dike <jdike@addtoit.com>, linux-parisc@vger.kernel.org, Chris Zankel <chris@zankel.net>, linux-arch@vger.kernel.org

On Wed, Sep 8, 2010 at 8:14 PM, Thomas Gleixner <tglx@linutronix.de> wrote:
> __do_IRQ() has been deprecated after a two years migration phase in
> =A0The following architectures are still using __do_IRQ():
>
> =A0alpha, cris, ia64, h8300, m32r, m68knommu, parisc, um
>

Maybe I'm naive but shouldn't this path work?
Does um need some extra work?

The linux executable aborts immediately when I apply my patch.

---cut---
Locating the bottom of the address space ... 0x10000
Locating the top of the address space ... 0xc0000000
Core dump limits :
        soft - 0
        hard - NONE
Checking that ptrace can change system call numbers...OK
Checking syscall emulation patch for ptrace...OK
Checking advanced syscall emulation patch for ptrace...OK
Checking for tmpfs mount on /dev/shm...nothing mounted on /dev/shm
Checking PROT_EXEC mmap in /tmp/...OK
Checking for the skas3 patch in the host:
  - /proc/mm...not found: No such file or directory
  - PTRACE_FAULTINFO...not found
  - PTRACE_LDT...not found
UML running in SKAS0 mode
Aborted
---cut---

diff --git a/arch/um/Kconfig.um b/arch/um/Kconfig.um
index ec2b8da..ae950e0 100644
--- a/arch/um/Kconfig.um
+++ b/arch/um/Kconfig.um
@@ -147,3 +147,8 @@ config KERNEL_STACK_ORDER
          This option determines the size of UML kernel stacks.  They will
          be 1 << order pages.  The default is OK unless you're running Val=
grind
          on UML, in which case, set this to 3.
+
+config GENERIC_HARDIRQS_NO__DO_IRQ
+       def_bool y
+
+
diff --git a/arch/um/kernel/irq.c b/arch/um/kernel/irq.c
index a3f0b04..3d44535 100644
--- a/arch/um/kernel/irq.c
+++ b/arch/um/kernel/irq.c
@@ -334,7 +334,7 @@ unsigned int do_IRQ(int irq, struct uml_pt_regs *regs)
 {
        struct pt_regs *old_regs =3D set_irq_regs((struct pt_regs *)regs);
        irq_enter();
-       __do_IRQ(irq);
+       generic_handle_irq(irq);
        irq_exit();
        set_irq_regs(old_regs);
        return 1;
