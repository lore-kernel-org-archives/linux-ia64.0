From: Keith Owens <kaos@ocs.com.au>
Date: Sun, 02 Dec 2001 03:56:44 +0000
Subject: [Linux-ia64] 2.4.16-ia64-011128 is missing dma64_addr_t
Message-Id: <marc-linux-ia64-105590698805568@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

2.4.16-ia64-011128 has no definition for dma64_addr_t.
drivers/scsi/sym53c8xx_2/sym_glue.c:306: parse error before `bus_addr_t'

Index: 16.6/include/asm-ia64/types.h
--- 16.6/include/asm-ia64/types.h Fri, 05 Jan 2001 13:42:29 +1100 kaos (linux-2.4/s/24_types.h 1.1 644)
+++ 16.6(w)/include/asm-ia64/types.h Sun, 02 Dec 2001 14:46:52 +1100 kaos (linux-2.4/s/24_types.h 1.1 644)
@@ -63,6 +63,7 @@ typedef __u64 u64;
 /* DMA addresses are 64-bits wide, in general.  */
 
 typedef u64 dma_addr_t;
+typedef u64 dma64_addr_t;
 
 # endif /* __KERNEL__ */
 #endif /* !__ASSEMBLY__ */


