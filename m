From: "David S. Miller" <davem@redhat.com>
Date: Fri, 16 May 2003 07:53:45 +0000
Subject: Re: [Linux-ia64] Re: 64 Bits DMA Addresses for Alloc Consistent
Message-Id: <marc-linux-ia64-105590723705896@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705823@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705823@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

   From: Jeremy Higdon <jeremy@sgi.com>
   Date: Fri, 16 May 2003 00:48:12 -0700
   
   Isn't that what dma_cache_wback_inv does?

That function is not part of the DMA api, and no portable
driver should use this dma_cache_wback_inv() thing.

