From: "David S. Miller" <davem@redhat.com>
Date: Fri, 16 May 2003 21:06:27 +0000
Subject: Re: [Linux-ia64] Re: 64 Bits DMA Addresses for Alloc Consistent
Message-Id: <marc-linux-ia64-105590723705912@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705823@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705823@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

   From: Jes Sorensen <jes@wildopensource.com>
   Date: 16 May 2003 17:02:36 -0400

   How does this patch look to you? It adds the generic code for setting
   the mask, it will then be up to Colin to fix the SGI SN2 specific code
   to honor it.
   
   I also added a patch to the tg3 driver to set the mask as it seems to
   work just dandy with 64 bit consistent addresses.
   
   Tested on ia64, but I see no reason why it should fail elsewhere.
   
I'd hate to say this but we probably need a
pci_consistent_dma_supported().

But this can wait and your patch is fine, EXCEPT the missing
documentation update :-)

