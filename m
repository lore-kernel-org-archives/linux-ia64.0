From: "David S. Miller" <davem@redhat.com>
Date: Thu, 15 May 2003 23:40:53 +0000
Subject: [Linux-ia64] Re: 64 Bits DMA Addresses for Alloc Consistent Interfaces.
Message-Id: <marc-linux-ia64-105590723705858@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705823@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705823@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

   From: Colin Ngam <cngam@sgi.com>
   Date: Thu, 15 May 2003 17:14:11 -0500
   
   Now, for PCI-X devices, we need to generate an IOMMU mapped DMA
   address that  has the Upper 32 bits non 0s.

Then add a consistent_dma_mask attribute to the device struct,
problem solved.

