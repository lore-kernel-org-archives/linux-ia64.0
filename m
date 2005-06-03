From: Russ Anderson <rja@sgi.com>
Date: Fri, 03 Jun 2005 18:27:54 +0000
Subject: Re: Initialization of cr.dcr
Message-Id: <200506031827.j53IRs8U1661317@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42A01CA2.8010209@hob.de>
In-Reply-To: <42A01CA2.8010209@hob.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Ken Chen wrote:
> 
> Christian Hildner wrote on Friday, June 03, 2005 2:02 AM
> > playing around with speculation I found that on initialization dcr.dm is 
> > not set, while the comment says "Initialize default control register to 
> > defer all speculative faults". To be conform to the comment (and also to 
> > the expected behavior) the value IA64_DCR_DM should be added in 
> > arch/ia64/kernel/setup.c.
> 
> It should be the other way around: update the comments to reflect what
> the code does.  Turning off dcr.dm is a big win for speculative load
> where you do want the tlb miss to be serviced up front.

  Virtual Memory in the IA-64 Linux Kernel
    * By Stephane Eranian, David Mosberger.

  A related problem arises from speculative loads in the kernel. If 
  TLB misses are not deferred (dcr.dm is 0), a speculative load inside
  the kernel may cause a TLB miss to an arbitrary address. If that
  address happens to fall inside region 6 or 7, the speculative load
  would trigger an alternate TLB fault. This again poses the risk of
  inserting a translation with conflicting memory attributes. To
  prevent this, the alternate DTLB miss handler also checks whether the
  faulting access was caused by a speculative load and, if so, turns on
  the exception deferral bit (ed in psr) instead of installing a
  translation. The net effect of this method is that all speculative
  loads to region 6 and 7 produce a NaT value, unless the translation
  for the page being accessed happens to be in the TLB already. This
  solution may sometimes produce a NaT unnecessarily, but apart from a
  small performance impact, does not affect the correct operation of
  the kernel. This solution also has the advantage that speculative
  loads cannot pollute the TLB with unnecessary translations.

http://www.informit.com/articles/article.asp?p)961&seqNum=5&rl=1

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
