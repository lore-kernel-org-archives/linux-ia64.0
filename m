From: Steven Cole <scole@lanl.gov>
Date: Wed, 25 Apr 2001 14:54:03 +0000
Subject: [Linux-ia64] [PATCH] 2.4.3-ac14 remove three IA-64 related orphans from Configure.help
Message-Id: <marc-linux-ia64-105590693005460@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Alan,

The following three Configure.help entries have been confirmed dead, or
not needing help by Keith Owens.  

The last of these, CONFIG_IA64_AZUSA_HACKS,  is listed by Keith as 
removed by a 2.4.2-ia64-010228 patch, but it still appears in 2.4.3-ac14.

Steven

--- linux/Documentation/Configure.help.ac14     Wed Apr 25 08:14:33 2001
+++ linux/Documentation/Configure.help  Wed Apr 25 08:40:50 2001
@@ -18611,22 +18611,6 @@
   redirect interrupts to different CPUs.  Select N here if you're
   unsure.
 
-Enable use of global TLB purge instruction (ptc.g)
-CONFIG_ITANIUM_PTCG
-  Say Y here if you want the kernel to use the IA-64 "ptc.g"
-  instruction to flush the TLB on all CPUs.  Select N here if
-  you're unsure.
-
-Enable SoftSDV hacks
-CONFIG_IA64_SOFTSDV_HACKS
-  Say Y here to enable hacks to make the kernel work on the Intel
-  SoftSDV simulator.  Select N here if you're unsure.
-
-Enable AzusA hacks
-CONFIG_IA64_AZUSA_HACKS
-  Say Y here to enable hacks to make the kernel work on the NEC
-  AzusA platform.  Select N here if you're unsure.
-
 Enable IA-64 Machine Check Abort
 CONFIG_IA64_MCA
   Say Y here to enable machine check support for IA-64.  If you're

