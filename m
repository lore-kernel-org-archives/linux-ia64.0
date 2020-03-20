From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Date: Fri, 20 Mar 2020 09:48:55 +0000
Subject: [PATCH 4/5] ia64: Remove mm.h from asm/uaccess.h
Message-Id: <20200320094856.3453859-5-bigeasy@linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200318204408.010461877@linutronix.de>
 <20200320094856.3453859-1-bigeasy@linutronix.de>
In-Reply-To: <20200320094856.3453859-1-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tglx@linutronix.de
Cc: arnd@arndb.de, balbi@kernel.org, bhelgaas@google.com, bigeasy@linutronix.de, dave@stgolabs.net, davem@davemloft.net, gregkh@linuxfoundation.org, joel@joelfernandes.org, kurt.schwemmer@microsemi.com, kvalo@codeaurora.org, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-usb@vger.kernel.org, linux-wireless@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, logang@deltatee.com, mingo@kernel.org, mpe@ellerman.id.au, netdev@vger.kernel.org, oleg@redhat.com, paulmck@kernel.org, peterz@infradead.org, rdunlap@infradead.org, rostedt@goodmis.org, torvalds@linux-foundation.org, will@kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, kbuild test robot <lkp@intel.com>

The defconfig compiles without linux/mm.h. With mm.h included the
include chain leands to:
|   CC      kernel/locking/percpu-rwsem.o
| In file included from include/linux/huge_mm.h:8,
|                  from include/linux/mm.h:567,
|                  from arch/ia64/include/asm/uaccess.h:,
|                  from include/linux/uaccess.h:11,
|                  from include/linux/sched/task.h:11,
|                  from include/linux/sched/signal.h:9,
|                  from include/linux/rcuwait.h:6,
|                  from include/linux/percpu-rwsem.h:8,
|                  from kernel/locking/percpu-rwsem.c:6:
| include/linux/fs.h:1422:29: error: array type has incomplete element type 'struct percpu_rw_semaphore'
|  1422 |  struct percpu_rw_semaphore rw_sem[SB_FREEZE_LEVELS];

once rcuwait.h includes linux/sched/signal.h.

Remove the linux/mm.h include.

Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
Reported-by: kbuild test robot <lkp@intel.com>
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 arch/ia64/include/asm/uaccess.h | 1 -
 arch/ia64/kernel/process.c      | 1 +
 arch/ia64/mm/ioremap.c          | 1 +
 3 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/arch/ia64/include/asm/uaccess.h b/arch/ia64/include/asm/uaccess.h
index 89782ad3fb887..5c7e79eccaeed 100644
--- a/arch/ia64/include/asm/uaccess.h
+++ b/arch/ia64/include/asm/uaccess.h
@@ -35,7 +35,6 @@
 
 #include <linux/compiler.h>
 #include <linux/page-flags.h>
-#include <linux/mm.h>
 
 #include <asm/intrinsics.h>
 #include <asm/pgtable.h>
diff --git a/arch/ia64/kernel/process.c b/arch/ia64/kernel/process.c
index 968b5f33e725e..743aaf5283278 100644
--- a/arch/ia64/kernel/process.c
+++ b/arch/ia64/kernel/process.c
@@ -681,3 +681,4 @@ machine_power_off (void)
 	machine_halt();
 }
 
+EXPORT_SYMBOL(ia64_delay_loop);
diff --git a/arch/ia64/mm/ioremap.c b/arch/ia64/mm/ioremap.c
index a09cfa0645369..55fd3eb753ff9 100644
--- a/arch/ia64/mm/ioremap.c
+++ b/arch/ia64/mm/ioremap.c
@@ -8,6 +8,7 @@
 #include <linux/module.h>
 #include <linux/efi.h>
 #include <linux/io.h>
+#include <linux/mm.h>
 #include <linux/vmalloc.h>
 #include <asm/io.h>
 #include <asm/meminit.h>
-- 
2.26.0.rc2
