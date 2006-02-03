From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 03 Feb 2006 18:43:08 +0000
Subject: RE: ia64 printk_clock()
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F059C109E@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060202204422.GA27082@sgi.com>
In-Reply-To: <20060202204422.GA27082@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Now that I read the whole thread, how about remove pining DTR 
> requirement for per-cpu data?  In alt_dtlb_miss, we can just
> detect whether ifa is per_cpu address and read ar.k3 to get the
> physical address, then insert a TC.  That will free up a tlb
> entry for application to use.

What will you do when someone accesses per-cpu area before ar.k3
has been initialized (the bug that we are trying to fix here)?

This would add some extra code to the Alt-DTLB handler.  Could
you hide all/most of the extra latency?

Are there any correctness issues?  Any place where we access a
per-cpu variable where we absolutely cannot take an Alt-DTLB fault?

-Tony
