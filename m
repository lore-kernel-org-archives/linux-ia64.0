From: Jeremy Higdon <jeremy@sgi.com>
Date: Fri, 16 May 2003 22:39:47 +0000
Subject: Re: [Linux-ia64] Re: 64 Bits DMA Addresses for Alloc Consistent Interfaces.
Message-Id: <marc-linux-ia64-105590723705914@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705823@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705823@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, May 16, 2003 at 02:06:27PM -0700, David S. Miller wrote:
> 
> But this can wait and your patch is fine, EXCEPT the missing
> documentation update :-)

From my reading of the Tigon driver, test DMA relies on a 32 bit address
from dma_alloc_consistent, whereas other consistent allocations seem to
be fine with a 64 bit address.

Do you have any problem with a patch to drivers/net/tg3.c to enable
the test DMA to be 64 bit?

--- /usr/tmp/TmpDir.15862-0/linux/drivers/net/tg3.c_1.20	2003-05-16 15:37:45.000000000 -0700
+++ linux/drivers/net/tg3.c	2003-05-16 15:35:40.000000000 -0700
@@ -6401,7 +6401,7 @@
 	tw32(FTQ_RESET, 0);
 
 	/* pci_alloc_consistent gives only non-DAC addresses */
-	test_desc.addr_hi = 0;
+	test_desc.addr_hi = ((u64) buf_dma >> 32);
 	test_desc.addr_lo = buf_dma & 0xffffffff;
 	test_desc.nic_mbuf = 0x00002100;
 	test_desc.len = size;

