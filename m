From: Russ Anderson <rja@sgi.com>
Date: Fri, 17 Sep 2004 19:43:16 +0000
Subject: Re: RFC - freeing up ar.k5
Message-Id: <200409171943.i8HJhGvb033457@ben.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200409162152.i8GLqwG01566@unix-os.sc.intel.com>
In-Reply-To: <200409162152.i8GLqwG01566@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony Luck wrote:
> 
> Well, this is what a patch to free up ar.k5 by replacing its use
> with a percpu variable looks like.
> 
> Downside is a possible cache miss reading the variable in 'schedule()'.
> 
> Upside is freeing up ar.k5 ... whose use would get rid of much ugliness
> in the mca tlb recovery code (and in the impending per-cpu save areas
> for INIT/MCA).

I certainly do not object to using ar.k5 for a percpu physical address pointer.  

Just to understand the rest, I assume this means:

  * The ia64_mca_tlb_list[] array goes away and each cpu will have a 
    ia64_mca_tlb_info structure (a physical address pointer to the structure 
    being in ar.k5).  The memory for each structure will be allocated on
    the same node as the CPU.

  * A physcial address pointer to the per data MCA/INIT area added to 
    the ia64_mca_tlb_info structure.

  * Then whe an MCA or INIT occurs, the pointer is waiting in ar.k5.

Thanks,
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
