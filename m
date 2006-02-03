From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 03 Feb 2006 18:55:03 +0000
Subject: RE: ia64 printk_clock()
Message-Id: <200602031855.k13It3g21683@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060202204422.GA27082@sgi.com>
In-Reply-To: <20060202204422.GA27082@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Luck, Tony wrote on Friday, February 03, 2006 10:43 AM
> > Now that I read the whole thread, how about remove pining DTR 
> > requirement for per-cpu data?  In alt_dtlb_miss, we can just
> > detect whether ifa is per_cpu address and read ar.k3 to get the
> > physical address, then insert a TC.  That will free up a tlb
> > entry for application to use.
> 
> What will you do when someone accesses per-cpu area before ar.k3
> has been initialized (the bug that we are trying to fix here)?

As far as I can tell, so far printk_clock is the only one that
needs to reference per_cpu area data before it is setup. Everywhere
else in ia64 arch code, it is specially crafted to avoid it.

Alternatively, we can do the same trick as boot strapping init_task,
having per cpu area allocated for BP in the kernel image and have
BP to setup per cpu area for AP before bringing them up.  Is that
worth it?


> This would add some extra code to the Alt-DTLB handler.  Could
> you hide all/most of the extra latency?

I will try ....


> Are there any correctness issues?  Any place where we access a
> per-cpu variable where we absolutely cannot take an Alt-DTLB fault?

Good point, I will look (don't think there is any place we reference
per cpu data with psr.ic off).

- Ken

