From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 03 Dec 2001 19:34:28 +0000
Subject: Re: [Linux-ia64] 2.4.16-ia64-011128 is missing dma64_addr_t
Message-Id: <marc-linux-ia64-105590698805582@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805568@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805568@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This error appears to be due to a bug in the sym53c8xx_2 driver.  Note
that dma64_addr_t should be used only for the pci_dac_* interface,
which I do not want to support on ia64 unless and until we absolutely
have to (technically, there is no need for pci_dac_* on ia64 or x86).

If you need a 64-bit integer type, just use u64 instead.

	--david

----------------------------------------------
From: Keith Owens <kaos@ocs.com.au>
Sender: linux-ia64-admin@linuxia64.org
To: linux-ia64@linuxia64.org
Subject: [Linux-ia64] 2.4.16-ia64-011128 is missing dma64_addr_t
Date: Sun, 02 Dec 2001 14:56:44 +1100

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


_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64

