From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 13 Jan 2004 19:26:36 +0000
Subject: [PATCH] ia64 system type Kconfig cleanup
Message-Id: <200401131226.36745.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Here's a 2.6 patch that corresponds to the one I just put in 2.4.
I can't get menuconfig to show me any of the help text, but that
seems to be a generic problem (happens on x86 as well).

=== arch/ia64/Kconfig 1.52 vs edited ==--- 1.52/arch/ia64/Kconfig	Mon Dec 29 23:09:39 2003
+++ edited/arch/ia64/Kconfig	Tue Jan 13 11:51:08 2004
@@ -66,26 +66,18 @@
 	  will run on any supported IA-64 system.  However, if you configure
 	  a kernel for your specific system, it will be faster and smaller.
 
-	  To find out what type of IA-64 system you have, you may want to
-	  check the IA-64 Linux web site at <http://www.linux-ia64.org/>.
-	  As of the time of this writing, most hardware is DIG compliant,
-	  so the "DIG-compliant" option is usually the right choice.
-
-	  HP-simulator   For the HP simulator
-	  (<http://software.hp.com/ia64linux/>).
-	  HP-zx1         For HP zx1-based systems.
-	  SGI-SN2	 For SGI Altix systems
 	  DIG-compliant  For DIG ("Developer's Interface Guide") compliant
-	  systems.
+	  systems
+	  HP-zx1         For HP systems
+	  SGI-SN2	 For SGI Altix systems
+	  Ski-simulator  For the HP simulator
+	  (<http://www.hpl.hp.com/research/linux/ski/>)
 
 	  If you don't know what to do, choose "generic".
 
 config IA64_DIG
 	bool "DIG-compliant"
 
-config IA64_HP_SIM
-	bool "HP-simulator"
-
 config IA64_HP_ZX1
 	bool "HP-zx1"
 	help
@@ -95,6 +87,9 @@
 
 config IA64_SGI_SN2
 	bool "SGI-SN2"
+
+config IA64_HP_SIM
+	bool "Ski-simulator"
 
 endchoice
 

