From: Jeremy Higdon <jeremy@classic.engr.sgi.com>
Date: Fri, 16 May 2003 23:40:25 +0000
Subject: Re: [Linux-ia64] Re: 64 Bits DMA Addresses for Alloc Consistent Interfaces.
Message-Id: <marc-linux-ia64-105590723705918@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705823@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705823@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> --- /usr/tmp/TmpDir.15862-0/linux/drivers/net/tg3.c_1.20	2003-05-16 15:37:45.000000000 -0700
> +++ linux/drivers/net/tg3.c	2003-05-16 15:35:40.000000000 -0700
> @@ -6401,7 +6401,7 @@
>  	tw32(FTQ_RESET, 0);
>  
>  	/* pci_alloc_consistent gives only non-DAC addresses */
> -	test_desc.addr_hi = 0;
> +	test_desc.addr_hi = ((u64) buf_dma >> 32);
>  	test_desc.addr_lo = buf_dma & 0xffffffff;
>  	test_desc.nic_mbuf = 0x00002100;
>  	test_desc.len = size;
> 

I guess this is better:
--- /usr/tmp/TmpDir.15906-0/linux/drivers/net/tg3.c_1.20	2003-05-16 15:41:19.000000000 -0700
+++ linux/drivers/net/tg3.c	2003-05-16 15:39:13.000000000 -0700
@@ -6400,8 +6400,7 @@
 	tw32(BUFMGR_MODE, 0);
 	tw32(FTQ_RESET, 0);
 
-	/* pci_alloc_consistent gives only non-DAC addresses */
-	test_desc.addr_hi = 0;
+	test_desc.addr_hi = ((u64) buf_dma >> 32);
 	test_desc.addr_lo = buf_dma & 0xffffffff;
 	test_desc.nic_mbuf = 0x00002100;
 	test_desc.len = size;

