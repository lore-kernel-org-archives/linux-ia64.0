From: jbarnes@sgi.com (Jesse Barnes)
Date: Tue, 30 Sep 2003 00:27:31 +0000
Subject: [PATCH] small update for Kconfig help text
Message-Id: <marc-linux-ia64-106488185518593@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Just a small update for the Kconfig help text for ia64.

Jesse

diff -Nru a/arch/ia64/Kconfig b/arch/ia64/Kconfig
--- a/arch/ia64/Kconfig	Mon Sep 29 17:06:17 2003
+++ b/arch/ia64/Kconfig	Mon Sep 29 17:06:17 2003
@@ -64,8 +64,6 @@
 
 	  To find out what type of IA-64 system you have, you may want to
 	  check the IA-64 Linux web site at <http://www.linux-ia64.org/>.
-	  As of the time of this writing, most hardware is DIG compliant,
-	  so the "DIG-compliant" option is usually the right choice.
 
 	  HP-simulator   For the HP simulator
 	  (<http://software.hp.com/ia64linux/>).
@@ -91,6 +89,11 @@
 
 config IA64_SGI_SN2
 	bool "SGI-SN2"
+	help
+	  Build a kernel for SGI sn2-based systems.  Choosing this option
+	  rather than building a generic kernel will provide a small
+	  performance boost at the cost of not being able to use the kernel
+	  binary on non-Altix systems.
 
 endchoice
 
