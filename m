From: William Lee Irwin III <wli@holomorphy.com>
Date: Sat, 13 Mar 2004 03:55:11 +0000
Subject: Re: Hugetlbpages in very large memory machines.......
Message-Id: <20040313035511.GZ655@holomorphy.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40528383.10305@sgi.com>
In-Reply-To: <40528383.10305@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ray Bryant <raybry@sgi.com>
Cc: lse-tech@lists.sourceforge.net, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, linux-kernel@vger.kernel.org

On Fri, Mar 12, 2004 at 09:44:03PM -0600, Ray Bryant wrote:
> We've run into a scaling problem using hugetlbpages in very large memory 
> machines, e. g. machines with 1TB or more of main memory.  The problem is 
> that hugetlbpage pages are not faulted in, rather they are zeroed and 
> mapped in in by hugetlb_prefault() (at least on ia64), which is called in 
> response to the user's mmap() request.  The net is that all of the hugetlb 
> pages end up being allocated and zeroed by a single thread, and if most of 
> the machine's memory is allocated to hugetlb pages, and there is 1 TB or 
> more of main memory, zeroing and allocating all of those pages can take a 
> long time (500 s or more).
> We've looked at allocating and zeroing hugetlbpages at fault time, which 
> would at least allow multiple processors to be thrown at the problem.  
> Question is, has anyone else been working on
> this problem and might they have prototype code they could share with us?

This actually is largely a question of architecture-dependent code, so
the answer will depend on whether your architecture matches those of the
others who have had a need to arrange this.

Basically, all you really need to do is to check the vma and call either
a hugetlb-specific fault handler or handle_mm_fault() depending on whether
hugetlb is configured. Once you've gotten that far, it's only a question
of implementing the methods to work together properly when driven by
upper layers.

The reason why this wasn't done up-front was that there wasn't a
demonstrable need to do so. The issue you're citing is exactly the kind
of demonstration needed to motivate its inclusion.


-- wli
