From: Christoph Hellwig <hch@caldera.de>
Date: Wed, 06 Feb 2002 08:21:29 +0000
Subject: Re: [Linux-ia64] Proper fix for sym53c8xx_2 driver and dma64_addr_t
Message-Id: <marc-linux-ia64-105590698805998@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805991@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805991@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Feb 05, 2002 at 01:44:06PM -0800, David Mosberger wrote:
>   Christoph> IA64 needs to define dma64_addr_t.
> 
> Not before the driver writers understand when to use it.

Architecture maintainers are not supposed to decide whether driver
writers understand APIs.  The dma64_addr_t type is part of the PCI
DMA interface and IA64 needs to defines it.

Linus, could you please accept the below patch to define dma64_addr_t
on IA64?

	Christoph

-- 
Of course it doesn't work. We've performed a software upgrade.

Index: include/asm-ia64/types.h
=================================RCS file: /vger/linux/include/asm-ia64/types.h,v
retrieving revision 1.3
diff -u -u -r1.3 types.h
--- include/asm-ia64/types.h	22 Apr 2000 00:45:18 -0000	1.3
+++ include/asm-ia64/types.h	6 Feb 2002 08:24:24 -0000
@@ -63,6 +63,7 @@
 /* DMA addresses are 64-bits wide, in general.  */
 
 typedef u64 dma_addr_t;
+typedef u64 dma64_addr_t;
 
 # endif /* __KERNEL__ */
 #endif /* !__ASSEMBLY__ */

