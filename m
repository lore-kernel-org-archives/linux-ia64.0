From: Russ Anderson <rja@sgi.com>
Date: Fri, 01 Oct 2004 21:35:28 +0000
Subject: Re: RFC - freeing up ar.k5
Message-Id: <200410012135.i91LZSVh060162@ben.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200409162152.i8GLqwG01566@unix-os.sc.intel.com>
In-Reply-To: <200409162152.i8GLqwG01566@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony Luck wrote:
> 
> Still not sure where to take this.  One suggestion I did get was to use
> this as a proof of concept that ar.k5 could be freed up if some super
> wonderful application for a ar.k register comes along, so it's ok to use
> our last completely free register (ar.k3) for the INIT/MCA code.

So which way should I go?

I could build on the current ia64_mca_tlb_info structure and avoid
the cpu reg issue, or use ar.k3 for the INIT/MCA code.

At this point I'm just interested in make some forward progress, so
either way is fine.

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
