From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 02 Feb 2005 01:04:49 +0000
Subject: RE: [patch] fix per-CPU MCA mess and make UP kernels work again
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02D58674@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16887.1203.470842.161249@napali.hpl.hp.com>
In-Reply-To: <16887.1203.470842.161249@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>> Russ ... Jesse ... can you ack when you test this.
>
>The system does not seem to recover as often with this patch, but
>I'm not sure why.  At first I thought it may be just reasonable
>varience, but after backing out the patch and re-running more times,
>then re-applying and re-re-running, it certainly looks like the
>test fails quicker with the patch.
>
>When it fails, it Oops's with an ip of 0, as if something was
>not restored properly.  But I have to dig deeper to find out 
>what is going on.

Any progress?

The only visible effect of this patch should be that the
ia64_mca_cpu structures for all cpus will be in one big block,
instead of scattered across nodes.  Perhaps there is an overrun
problem so one cpu is corrupting data that belongs to an adjacent
cpu.  When the allocations are scattered you might notice this
less often?

-Tony
