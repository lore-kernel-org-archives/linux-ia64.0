From: "David S. Miller" <davem@redhat.com>
Date: Thu, 15 May 2003 23:53:30 +0000
Subject: [Linux-ia64] Re: 64 Bits DMA Addresses for Alloc Consistent Interfaces.
Message-Id: <marc-linux-ia64-105590723705863@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705823@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705823@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

   From: Colin Ngam <cngam@sgi.com>
   Date: Thu, 15 May 2003 18:32:31 -0500
   
   I do not understand what you are saying .. how would a consistent_dma_mask
   attribute in the device struct helps pci_alloc_consistent() to return a dma
   hanlde that can have the Upper 32 Bits Non 0's, and, moreover,
   these Upper 32 Bits are not constants, but can vary greatly, and is
   part of the 64 bit Physical System Memory Address?
   
The mask says that the consistent address "can" have the upper
32-bits non-zero.  Then you define a consistent_dma_attrs bitmask
that can define things like "requires >4GB address" etc.

Again, all of this is device attribute stuff and not an issue
concerning the DMA api calls.

But I am ever further confused, how do things like tg3 cards even
function TODAY on any PCI-X systems.

