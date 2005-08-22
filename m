From: Arun Sharma <arun.sharma@intel.com>
Date: Mon, 22 Aug 2005 22:22:16 +0000
Subject: Re: Xen and the Art of Linux/ia64 Virtualization
Message-Id: <430A5018.4070600@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <516F50407E01324991DD6D07B0531AD54FA228@cacexc12.americas.cpqcorp.net>
In-Reply-To: <516F50407E01324991DD6D07B0531AD54FA228@cacexc12.americas.cpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Magenheimer, Dan (HP Labs Fort Collins) wrote:
> 
> Define "high performance hypervisor"... Would "within a
> few percent of native" qualify?  Xen/ia64 admittedly hasn't
> gone through a wide range of performance tests but
> domain0* currently compiles linux at only 4% slower than
> native and I expect this to get closer to 2% with some more
> work (and without additional changes to the patch).  A domU*
> guest will be slower due to I/O overhead but I/O is already
> using higher level primitives (the same ones as x86).

That's certainly impressive! SMP, more I/O intensive workloads and domU 
would be interesting as well.

I think xenlinux/ia64 is assuming that the memory allocated to dom0 is 
machine contiguous. This is not supported by the balloon driver and the 
netfront driver in drivers/xen. They change the guest physical -> 
machine physical mapping for dom0 at runtime.

Dealing with the non-contiguity might impose some I/O performance 
overheads, but that's orthogonal to the "is the instruction level 
approach sufficient?" or "is it a good first step?" debate.

All I'm saying is that if there is a divergence on this question from 
x86, sharing common driver code might become an issue.

	-Arun
