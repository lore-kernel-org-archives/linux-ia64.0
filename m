From: Jes Sorensen <jes@sgi.com>
Date: Thu, 02 Feb 2006 10:02:15 +0000
Subject: [patch] Build drivers/sn/ for all sn2 builds
Message-Id: <yq01wymoz88.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@osdl.org>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Dave Jones <davej@redhat.com>, tony.luck@intel.com

Hi,

Reposting this patch which solves the problem where drivers/sn isn't
being evaluated by the build system for some config cases.

Solves a problem earlier reported by Dave Jones.

Cheers,
Jes

Include drivers/sn when CONFIG_IA64_SGI_SN2 or CONFIG_IA64_GENERIC
is enabled.

Signed-off-by: Jes Sorensen <jes@sgi.com>
----

 arch/ia64/Kconfig |    3 +++
 drivers/Makefile  |    2 +-
 2 files changed, 4 insertions(+), 1 deletion(-)

Index: linux-2.6/arch/ia64/Kconfig
=================================--- linux-2.6.orig/arch/ia64/Kconfig
+++ linux-2.6/arch/ia64/Kconfig
@@ -374,6 +374,9 @@
 	  To use this option, you have to ensure that the "/proc file system
 	  support" (CONFIG_PROC_FS) is enabled, too.
 
+config SGI_SN
+	def_bool y if (IA64_SGI_SN2 || IA64_GENERIC)
+
 source "drivers/firmware/Kconfig"
 
 source "fs/Kconfig.binfmt"
Index: linux-2.6/drivers/Makefile
=================================--- linux-2.6.orig/drivers/Makefile
+++ linux-2.6/drivers/Makefile
@@ -69,7 +69,7 @@
 obj-$(CONFIG_CPU_FREQ)		+= cpufreq/
 obj-$(CONFIG_MMC)		+= mmc/
 obj-$(CONFIG_INFINIBAND)	+= infiniband/
-obj-$(CONFIG_SGI_IOC4)		+= sn/
+obj-$(CONFIG_SGI_SN)		+= sn/
 obj-y				+= firmware/
 obj-$(CONFIG_CRYPTO)		+= crypto/
 obj-$(CONFIG_SUPERH)		+= sh/
