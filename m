From: Darren Williams <dsw@gelato.unsw.edu.au>
Date: Wed, 25 Feb 2004 01:30:51 +0000
Subject: Re: 2.6.3 oops ia64 Itanium1 with Silicon Image IDE
Message-Id: <20040225013051.GF18070@cse.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040220005623.GI11475@cse.unsw.EDU.AU>
In-Reply-To: <20040220005623.GI11475@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi David

So with the correct changes the patch below boots with the 32bit pci silicon
image ide controller and 4GB of ram on Itanium 1.

When physical memory reaches or exceeds 4GB
some 32bit pci cards cannot directly access
the upper bound of phys memory therefore
we need to tell these cards that 4GB is
thier limit.


--- linux-2.6.3/include/asm-ia64/scatterlist.h  2004-02-16 09:41:56.000000000 +1100
+++ linux-2.6.3-latest/include/asm-ia64/scatterlist.h   2004-02-25 12:20:21.000000000 +1100
@@ -15,6 +15,6 @@
        unsigned int dma_length;
 };
  
-#define ISA_DMA_THRESHOLD      (~0UL)
+#define ISA_DMA_THRESHOLD      (0xffffffff)
  
 #endif /* _ASM_IA64_SCATTERLIST_H */
 




On Mon, 23 Feb 2004, David Mosberger wrote:

> 
>  Darren> Hi David
>  Darren> PCI_DMA_BUS_IS_PHYS to 0
> 
>  Darren> boots OK
> 
>  Darren> PCI_DMA_BUS_IS_PHYS Oxffffffff
>  Darren> &
>  Darren> PCI_DMA_BUS_IS_PHYS OxffffffffUL
> 
>  Darren> fail
> 
> Sorry, apparently I wasn't clear: PCI_DMA_BUS_IS_PHYS is a boolean, so
> it makes no sense to set it to anything other than 0 or 1.  What I
> meant for the second option is to leave PCI_DMA_BUS_IS_PHYS to 1 and
> then to set the ISA_DMA_THRESHOLD to 0xffffffff.
> 
>  Darren> Before continuing with this there are more serious problems
>  Darren> with the slab layer, see my post (BUG) slab error....
> 
> I saw your mails, but haven't seen this problem myself.
> 
> 	--david
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
--------------------------------------------------
Darren Williams <dsw AT gelato.unsw.edu.au>
Gelato@UNSW <www.gelato.unsw.edu.au>
--------------------------------------------------
