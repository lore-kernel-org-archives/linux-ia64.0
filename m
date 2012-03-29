From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 29 Mar 2012 20:35:22 +0000
Subject: [PATCH] Fix ia64 build errors (fallout from system.h disintegration)
Message-Id: <4f74c78a501635b91@agluck-desktop.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

In file included from include/linux/sched.h:92,
                from arch/ia64/kernel/asm-offsets.c:9:
include/linux/llist.h:59:25: error: asm/cmpxchg.h: No such file or directory
make[1]: *** [arch/ia64/kernel/asm-offsets.s] Error 1

Right now we don't seem to need any actual contents for the
asm/cmpxchg.h to make the build work ... so leave the migration
of xchg() and cmpxchg() to this new header file for a future patch.

Also process.c needs <asm/switch_to.h> (for definition of pfm_syst_info).

Signed-off-by: Tony Luck <tony.luck@intel.com>

---

diff --git a/arch/ia64/include/asm/cmpxchg.h b/arch/ia64/include/asm/cmpxchg.h
new file mode 100644
index 0000000..507c66c
--- /dev/null
+++ b/arch/ia64/include/asm/cmpxchg.h
@@ -0,0 +1 @@
+/* Future home of xchg() and cmpxchg() */
diff --git a/arch/ia64/kernel/process.c b/arch/ia64/kernel/process.c
index 9dc52b6..ce74e14 100644
--- a/arch/ia64/kernel/process.c
+++ b/arch/ia64/kernel/process.c
@@ -38,6 +38,7 @@
 #include <asm/pgalloc.h>
 #include <asm/processor.h>
 #include <asm/sal.h>
+#include <asm/switch_to.h>
 #include <asm/tlbflush.h>
 #include <asm/uaccess.h>
 #include <asm/unwind.h>
