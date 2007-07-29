From: Jesper Juhl <jesper.juhl@gmail.com>
Date: Sun, 29 Jul 2007 22:27:51 +0000
Subject: [PATCH] ia64: Remove a few duplicate includes
Message-Id: <200707300027.51839.jesper.juhl@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,


This patch removes a few duplicate includes from arch/ia64/


Please consider merging :-)


Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
---

 arch/ia64/ia32/sys_ia32.c   |    1 -
 arch/ia64/kernel/setup.c    |    1 -
 arch/ia64/sn/kernel/setup.c |    1 -
 3 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/arch/ia64/ia32/sys_ia32.c b/arch/ia64/ia32/sys_ia32.c
index af10462..a3405b3 100644
--- a/arch/ia64/ia32/sys_ia32.c
+++ b/arch/ia64/ia32/sys_ia32.c
@@ -34,7 +34,6 @@
 #include <linux/uio.h>
 #include <linux/nfs_fs.h>
 #include <linux/quota.h>
-#include <linux/syscalls.h>
 #include <linux/sunrpc/svc.h>
 #include <linux/nfsd/nfsd.h>
 #include <linux/nfsd/cache.h>
diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index 7cecd29..cd9a37a 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -60,7 +60,6 @@
 #include <asm/smp.h>
 #include <asm/system.h>
 #include <asm/unistd.h>
-#include <asm/system.h>
 
 #if defined(CONFIG_SMP) && (IA64_CPU_SIZE > PAGE_SIZE)
 # error "struct cpuinfo_ia64 too big!"
diff --git a/arch/ia64/sn/kernel/setup.c b/arch/ia64/sn/kernel/setup.c
index 684b1c9..1f38a3a 100644
--- a/arch/ia64/sn/kernel/setup.c
+++ b/arch/ia64/sn/kernel/setup.c
@@ -25,7 +25,6 @@
 #include <linux/interrupt.h>
 #include <linux/acpi.h>
 #include <linux/compiler.h>
-#include <linux/sched.h>
 #include <linux/root_dev.h>
 #include <linux/nodemask.h>
 #include <linux/pm.h>


