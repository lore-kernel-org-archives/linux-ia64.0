From: "David S. Miller" <davem@redhat.com>
Date: Wed, 06 Feb 2002 08:29:06 +0000
Subject: Re: [Linux-ia64] Proper fix for sym53c8xx_2 driver and dma64_addr_t
Message-Id: <marc-linux-ia64-105590698805999@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805991@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805991@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

   From: Christoph Hellwig <hch@caldera.de>
   Date: Wed, 6 Feb 2002 09:21:29 +0100

   On Tue, Feb 05, 2002 at 01:44:06PM -0800, David Mosberger wrote:
   >   Christoph> IA64 needs to define dma64_addr_t.
   > 
   > Not before the driver writers understand when to use it.
   
   Architecture maintainers are not supposed to decide whether driver
   writers understand APIs.  The dma64_addr_t type is part of the PCI
   DMA interface and IA64 needs to defines it.

You do have a point, but so does David.

What driver wants to get at this type and what are they using it
for?  dma_addr_t should be used by every driver I am aware of
except the clustering PCI cards I've been told about and that
driver isn't in the kernel at this time.

So who needs it? :-)


