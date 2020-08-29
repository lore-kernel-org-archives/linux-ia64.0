From: Masahiro Yamada <masahiroy@kernel.org>
Date: Sat, 29 Aug 2020 05:15:23 +0000
Subject: [PATCH 2/3] ia64: remove unneeded header includes from <asm/mca.h>
Message-Id: <20200829051524.706585-3-masahiroy@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200829051524.706585-1-masahiroy@kernel.org>
In-Reply-To: <20200829051524.706585-1-masahiroy@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org
Cc: Randy Dunlap <rdunlap@infradead.org>, linux-kbuild@vger.kernel.org, Masahiro Yamada <masahiroy@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Ard Biesheuvel <ardb@kernel.org>, Dmitry Safonov <0x7f454c46@gmail.com>, afzal mohammed <afzal.mohd.ma@gmail.com>, linux-efi@vger.kernel.org, linux-kernel@vger.kernel.org

<asm/mca.h> includes too many unneeded headers.

This commit cuts off a lot of header includes.

What we need to include are:

 - <linux/percpu.h> for DECLARE_PER_CPU(u64, ia64_mca_pal_base)
 - <linux/threads.h> for NR_CPUS
 - <linux/types.h> for u8, u64, size_t, etc.
 - <asm/ptrace.h> for KERNEL_STACK_SIZE

The other header includes are actually unneeded.

<asm/mca.h> previously included 436 headers, and now it includes
only 138. I confirmed <asm/mca.h> is still self-contained.

Signed-off-by: Masahiro Yamada <masahiroy@kernel.org>
---

 arch/ia64/include/asm/mca.h | 9 +++------
 arch/ia64/kernel/efi.c      | 1 +
 arch/ia64/kernel/mca.c      | 1 +
 3 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/arch/ia64/include/asm/mca.h b/arch/ia64/include/asm/mca.h
index c92b9c15962c..05805249296c 100644
--- a/arch/ia64/include/asm/mca.h
+++ b/arch/ia64/include/asm/mca.h
@@ -14,13 +14,10 @@
 
 #if !defined(__ASSEMBLY__)
 
-#include <linux/interrupt.h>
+#include <linux/percpu.h>
+#include <linux/threads.h>
 #include <linux/types.h>
-
-#include <asm/param.h>
-#include <asm/sal.h>
-#include <asm/processor.h>
-#include <asm/mca_asm.h>
+#include <asm/ptrace.h>
 
 #define IA64_MCA_RENDEZ_TIMEOUT		(20 * 1000)	/* value in milliseconds - 20 seconds */
 
diff --git a/arch/ia64/kernel/efi.c b/arch/ia64/kernel/efi.c
index f932b25fb817..b6bb718ed1ff 100644
--- a/arch/ia64/kernel/efi.c
+++ b/arch/ia64/kernel/efi.c
@@ -39,6 +39,7 @@
 #include <asm/meminit.h>
 #include <asm/processor.h>
 #include <asm/mca.h>
+#include <asm/sal.h>
 #include <asm/setup.h>
 #include <asm/tlbflush.h>
 
diff --git a/arch/ia64/kernel/mca.c b/arch/ia64/kernel/mca.c
index 17151269d655..3911c561d2bb 100644
--- a/arch/ia64/kernel/mca.c
+++ b/arch/ia64/kernel/mca.c
@@ -96,6 +96,7 @@
 #include <asm/ptrace.h>
 #include <asm/sal.h>
 #include <asm/mca.h>
+#include <asm/mca_asm.h>
 #include <asm/kexec.h>
 
 #include <asm/irq.h>
-- 
2.25.1
