From: "Mallick, Asit K" <asit.k.mallick@intel.com>
Date: Thu, 11 Jan 2001 01:14:16 +0000
Subject: RE: [Linux-ia64] Kernel panic in dtlb_fault
Message-Id: <marc-linux-ia64-105590693005019@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205904@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205904@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Here is a patch to fix this problem.

Thanks,
Asit

--- linux-2.4.0/arch/ia64/kernel/ivt.S  Tue Jan  9 03:48:36 2001
+++ linux/arch/ia64/kernel/ivt.S        Wed Jan 10 06:32:56 2001
@@ -206,6 +206,7 @@
        ;;
 (p7)   ptc.l r16,r20
 #endif
+       mov b0=r29
        mov pr=r31,-1
        rfi
        ;;
@@ -241,6 +242,7 @@
        ;;
 (p7)   ptc.l r16,r20
 #endif
+       mov b0=r29
        mov pr=r31,-1
        rfi
        ;;




