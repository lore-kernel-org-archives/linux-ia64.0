From: "David S. Miller" <davem@redhat.com>
Date: Fri, 16 May 2003 00:11:41 +0000
Subject: [Linux-ia64] Re: 64 Bits DMA Addresses for Alloc Consistent Interfaces.
Message-Id: <marc-linux-ia64-105590723705870@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705823@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705823@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

   From: Colin Ngam <cngam@sgi.com>
   Date: Thu, 15 May 2003 18:51:35 -0500
   
   Implementation details aside, you are agreeing that the
   pci_alloc_consistent() interface can return an address > 4GB and we
   can document as such?

I can return an address that matches the requirements specified by
dev->consistent_dma_mask which is set by default to 0xffffffff and
must be changed by a device driver if it wants to use a non-default
value.

