From: "Howell, David P" <david.p.howell@intel.com>
Date: Mon, 05 May 2003 19:35:03 +0000
Subject: RE: [Linux-ia64] [PATCH] Increase size of user stack
Message-Id: <marc-linux-ia64-105590723705639@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705637@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705637@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Wouldn't it be better to base this off an rlimit?

Thanks,
Dave Howell


These are my opinions and not official opinions of Intel Corp.

David Howell
Intel Corporation
Telco Server Development
Server Products Division
Voice: (803) 461-6112  Fax: (803) 461-6292

Intel Corporation
Columbia Design Center, CBA-2
250 Berryhill Road, Suite 100
Columbia, SC 29210

david.p.howell@intel.com


-----Original Message-----
From: Martin Hicks [mailto:mort@wildopensource.com] 
Sent: Monday, May 05, 2003 2:19 PM
To: linux-ia64@linuxia64.org
Cc: Bjorn Helgaas; David Mosberger
Subject: [Linux-ia64] [PATCH] Increase size of user stack


Hello,

The current user stack size limit of 2GB is not big enough for large 
SMP or SSI clusters.  The following patch increases this size from 
2GB to 512GB.  The new size is negotiable, but right now SGI has 
programs that require over 100GB of stack size on a 64 processor 
machine.  Setting the user stack size to 512GB seems like 
a reasonable thing to do for future growth.

The patch is against 2.4.21-bk but it applies against 2.5 as well.

Comments?
mh

-- 
Wild Open Source Inc.                  mort@wildopensource.com


===== include/asm-ia64/a.out.h 1.4 vs edited =====
--- 1.4/include/asm-ia64/a.out.h	Thu Feb 28 06:57:29 2002
+++ edited/include/asm-ia64/a.out.h	Mon May  5 16:39:03 2003
@@ -32,7 +32,7 @@
 #ifdef __KERNEL__
 # include <asm/page.h>
 # define STACK_TOP	(0x6000000000000000UL + (1UL << (4*PAGE_SHIFT -
12)) - PAGE_SIZE)
-# define IA64_RBS_BOT	(STACK_TOP - 0x80000000L + PAGE_SIZE)	/*
bottom of reg. backing store */
+# define IA64_RBS_BOT	(STACK_TOP - 0x8000000000UL + PAGE_SIZE)
/* bottom of reg. backing store */
 #endif
 
 #endif /* _ASM_IA64_A_OUT_H */

_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64

