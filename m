From: Bjorn Helgaas <bhelgaas@google.com>
Date: Sun, 12 Jul 2015 22:01:45 +0000
Subject: [PATCH 0/3] IRQ trivial clarifications
Message-Id: <20150712215559.7166.33068.stgit@bhelgaas-glaptop2.roam.corp.google.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-arch@vger.kernel.org, linux-mips@linux-mips.org, linux-am33-list@redhat.com, linux-ia64@vger.kernel.org, linux-c6x-dev@linux-c6x.org, linux-parisc@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, adi-buildroot-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-alpha@vger.kernel.org, x86@kernel.org, linuxppc-dev@lists.ozlabs.org

These don't fix anything at all.  But they might make code understanding
and debugging slightly easier.

---

Bjorn Helgaas (3):
      x86, irq: Rename VECTOR_UNDEFINED and VECTOR_RETRIGGERED to IRQ_*
      x86, irq: Clarify "No irq handler" message
      IRQ: Print "unexpected IRQ" messages consistently across architectures


 arch/alpha/kernel/irq.c            |    2 +-
 arch/blackfin/kernel/irqchip.c     |    2 +-
 arch/c6x/kernel/irq.c              |    2 +-
 arch/ia64/kernel/irq.c             |    2 +-
 arch/m68k/include/asm/hardirq.h    |    2 +-
 arch/mips/kernel/irq.c             |    2 +-
 arch/mn10300/kernel/irq.c          |    2 +-
 arch/parisc/include/asm/hardirq.h  |    2 +-
 arch/powerpc/include/asm/hardirq.h |    2 +-
 arch/s390/include/asm/hardirq.h    |    2 +-
 arch/sh/kernel/irq.c               |    2 +-
 arch/tile/kernel/irq.c             |    2 +-
 arch/x86/include/asm/hw_irq.h      |    4 ++--
 arch/x86/kernel/apic/vector.c      |   14 +++++++-------
 arch/x86/kernel/irq.c              |   19 +++++++++----------
 arch/x86/kernel/irqinit.c          |    4 ++--
 include/asm-generic/hardirq.h      |    2 +-
 17 files changed, 33 insertions(+), 34 deletions(-)
