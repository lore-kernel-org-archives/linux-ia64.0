From: Tim Abbott <tabbott@MIT.EDU>
Date: Fri, 01 May 2009 00:04:07 +0000
Subject: [PATCH 5/5] ia64: convert to new generic read_mostly support.
Message-Id: <1241136247-10623-6-git-send-email-tabbott@mit.edu>
List-Id: <linux-ia64.vger.kernel.org>
References: <1241136247-10623-1-git-send-email-tabbott@mit.edu>
 <1241136247-10623-2-git-send-email-tabbott@mit.edu>
 <1241136247-10623-3-git-send-email-tabbott@mit.edu>
 <1241136247-10623-4-git-send-email-tabbott@mit.edu>
 <1241136247-10623-5-git-send-email-tabbott@mit.edu>
In-Reply-To: <1241136247-10623-5-git-send-email-tabbott@mit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sam Ravnborg <sam@ravnborg.org>
Cc: Linux kernel mailing list <linux-kernel@vger.kernel.org>, Anders Kaseorg <andersk@MIT.EDU>, Waseem Daher <wdaher@MIT.EDU>, Denys Vlasenko <vda.linux@googlemail.com>, Jeff Arnold <jbarnold@MIT.EDU>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Tim Abbott <tabbott@MIT.EDU>

Signed-off-by: Tim Abbott <tabbott@mit.edu>
Cc: Tony Luck <tony.luck@intel.com>
Cc: linux-ia64@vger.kernel.org
---
 arch/ia64/Kconfig             |    3 +++
 arch/ia64/include/asm/cache.h |    2 --
 arch/ia64/xen/xensetup.S      |    3 ++-
 3 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 294a3b1..1e2cd63 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -91,6 +91,9 @@ config GENERIC_TIME_VSYSCALL
 config HAVE_SETUP_PER_CPU_AREA
 	def_bool y
 
+config HAVE_READ_MOSTLY_DATA
+	def_bool y
+
 config DMI
 	bool
 	default y
diff --git a/arch/ia64/include/asm/cache.h b/arch/ia64/include/asm/cache.h
index e7482bd..8f72e1b 100644
--- a/arch/ia64/include/asm/cache.h
+++ b/arch/ia64/include/asm/cache.h
@@ -24,6 +24,4 @@
 # define SMP_CACHE_BYTES	(1 << 3)
 #endif
 
-#define __read_mostly __attribute__((__section__(".data.read_mostly")))
-
 #endif /* _ASM_IA64_CACHE_H */
diff --git a/arch/ia64/xen/xensetup.S b/arch/ia64/xen/xensetup.S
index 28fed1f..8781561 100644
--- a/arch/ia64/xen/xensetup.S
+++ b/arch/ia64/xen/xensetup.S
@@ -10,11 +10,12 @@
 #include <asm/system.h>
 #include <asm/paravirt.h>
 #include <asm/xen/privop.h>
+#include <linux/cache.h>
 #include <linux/elfnote.h>
 #include <linux/init.h>
 #include <xen/interface/elfnote.h>
 
-	.section .data.read_mostly
+	__READ_MOSTLY
 	.align 8
 	.global xen_domain_type
 xen_domain_type:
-- 
1.6.2.1

