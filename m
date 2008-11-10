From: Yasunori Goto <y-goto@jp.fujitsu.com>
Date: Mon, 10 Nov 2008 04:47:51 +0000
Subject: [Q] Why does dma_alloc_coherent() of ia64 GFP_DMA?
Message-Id: <20081110121123.F82A.E1E9C6FF@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, linux-ia64@vger.kernel.org, Linux Kernel ML <linux-kernel@vger.kernel.org>, Joerg Roedel <joerg.roedel@amd.com>


Hello. 

I have a (may be dumb) question about dma_alloc_coherent() for ia64.


Why does dma_alloc_coherent() of ia64 force GFP_DMA yet?
And why is swiotlb_dma_alloc_coherent() default routine of
platform_dma_alloc_coherent()?

-------
#define dma_alloc_coherent(dev, size, handle, gfp)      \
        platform_dma_alloc_coherent(dev, size, handle, (gfp) | GFP_DMA)
--------

Even if a device allows over 4G access and the driver doesn't specify
GFP_DMA, dma_alloc_coherent() returns under 4G area.
I guess many people think this is not so big issue because drivers require
very small memory generally.

However, I think this has the possibility of a finishing blow of OOM.
For example,

  1) Page caches occupy normal zone, and DMA zone is free.
  2) A user's application requires a few GB memory and mlock it.
     All DMA zone is occupied by it.
  3) A device which allows over 4GB is hot-added.
     But dma_alloc_coherent() try to allocate DMA zone.
     Then OOM occurs because there is no freeable pages.

I heard there are some users who require a few GB mlock.
There are similar trouble in past. 


If GFP_DMA is removed from above definition of dma_alloc_coherent(),
what will happen?

If it is not allowed, how is followings?

dma_alloc_coherent()
  -> platform_dma_alloc_coherent()
       -> normal_alloc_coherent()
          {
                 if (dma_mask allow over 4G)
                        ret = __get_free_pages();
				:
                        (check validation of returned address)
				:
                 else 
                        swiotlb_alloc_coherent();
          }
}

If I'm something misunderstanding, please let me know.


Thanks.

-- 
Yasunori Goto 


