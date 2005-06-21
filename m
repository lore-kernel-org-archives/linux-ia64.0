From: Greg Edwards <edwardsg@sgi.com>
Date: Tue, 21 Jun 2005 18:29:51 +0000
Subject: [PATCH] enable SGI simulator for generic kernels
Message-Id: <20050621182951.GC3892@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Allow the SGI simulator (medusa) to work on generic kernels.  There is
no inherent dependency on an sn2-specific kernel.

Boot tested on Altix, medusa and HP rx2600.

Signed-off-by: Greg Edwards <edwardsg@sgi.com>


 arch/ia64/Kconfig |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

Index: git-linus/arch/ia64/Kconfig
=================================--- git-linus.orig/arch/ia64/Kconfig	2005-06-15 16:21:44.857315858 -0500
+++ git-linus/arch/ia64/Kconfig	2005-06-21 10:40:57.812371106 -0500
@@ -216,7 +216,7 @@ config IOSAPIC
 
 config IA64_SGI_SN_SIM
 	bool "SGI Medusa Simulator Support"
-	depends on IA64_SGI_SN2
+	depends on IA64_SGI_SN2 || IA64_GENERIC
 	help
 	  If you are compiling a kernel that will run under SGI's IA-64
 	  simulator (Medusa) then say Y, otherwise say N.
