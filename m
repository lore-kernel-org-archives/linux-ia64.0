From: Alex Williamson <alex.williamson@hp.com>
Date: Mon, 25 Aug 2003 15:53:24 +0000
Subject: [PATH] 2.6, no discontig w/o NUMA
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------7F14DC367987B85578D5C7C6"
Message-Id: <marc-linux-ia64-106182688431120@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------7F14DC367987B85578D5C7C6
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit


   Currently the generic kernel won't build if you turn off NUMA
support.  Seems discontig support is too entangled with NUMA
support to live without it.  This patch makes it behave a bit
more friendly.  Thanks,

	Alex
-- 
Alex Williamson                             HP Linux & Open Source Lab
--------------7F14DC367987B85578D5C7C6
Content-Type: text/plain; charset=us-ascii;
 name="discontig_kconfig.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="discontig_kconfig.diff"

--- linux-2.6.0-test3.orig/arch/ia64/Kconfig	2003-08-25 09:04:18.000000000 -0600
+++ linux-2.6.0-test3/arch/ia64/Kconfig	2003-08-25 09:24:33.000000000 -0600
@@ -234,8 +234,8 @@
 endchoice
 
 config DISCONTIGMEM
-	bool "Discontiguous memory support" if (IA64_DIG && NUMA)
-	default y if IA64_SGI_SN2 || IA64_GENERIC
+	bool "Discontiguous memory support" if (IA64_DIG || IA64_SGI_SN2 || IA64_GENERIC) && NUMA
+	default y if (IA64_SGI_SN2 || IA64_GENERIC) && NUMA
 	help
 	  Say Y to support efficient handling of discontiguous physical memory,
 	  for architectures which are either NUMA (Non-Uniform Memory Access)

--------------7F14DC367987B85578D5C7C6--

