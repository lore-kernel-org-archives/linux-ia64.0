From: Christoph Hellwig <hch@infradead.org>
Date: Thu, 04 Dec 2003 13:11:43 +0000
Subject: Re: Problem booting Adaptec Ultra 320 driver with discontigmem support.
Message-Id: <marc-linux-ia64-107054357725969@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107054139923799@msgid-missing>
In-Reply-To: <marc-linux-ia64-107054139923799@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Dec 04, 2003 at 01:37:21PM +0100, Xavier Bru wrote:
> Hello, all
> 
> Running  2.6.0-test11 with Adaptec Ultra 320 driver that provides full 
> 64-bit support
> we hit a BUG in blk_queue_bounce_limit() due to physical address greater 
> than allowed by the dma mask.
> Having a look into the code, it appears that the computation to allow 
> full 64-bit support takes in account the size of the installed memory 
> instead of the max physical address of the platform.
> For example on  a platform with 32GB of memory distributed in 1 TB 
> physical address space, only 39-bits physical addresses are supported 
> instead of the 40 bits needed.

Still the wrong thing to do.  It should just check sizeof(dma_addr_t), that
the only sane check.

