From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 29 Mar 2006 07:11:12 +0000
Subject: RE: Prefetch mmap_sem in ia64_do_page_fault()
Message-Id: <200603290710.k2T7ARg03998@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0603282251410.20180@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603282251410.20180@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Christoph Lameter wrote on Tuesday, March 28, 2006 10:55 PM
> Take a hint from an x86_64 optimization by Arjan van de Ven and use it
> for ia64.
> 
> ...
> 
> Prefetch the mmap_sem, which is critical for the performance of the page fault
> handler. Maybe we can offset the damage done by the kprobes notifier?
> 
> Note: mm may be NULL but I guess that is safe. See 
> 
> +	/* mmap_sem is performance critical.... */
> +	prefetchw(&mm->mmap_sem);
> +

I would say push that a couple of lines down after checking !mm

        if (in_atomic() || !mm)
                goto no_context;

If you insist on prefetching mmap_sem at the very beginning of the
function, then use speculative load, it will "nat" right away with
null pointer without generating any exception at all.  It is super
fast because of nat page.

- Ken
