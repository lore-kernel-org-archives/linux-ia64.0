From: Russ Anderson <rja@sgi.com>
Date: Thu, 03 Feb 2005 23:48:26 +0000
Subject: Re: [patch] fix per-CPU MCA mess and make UP kernels work again
Message-Id: <200502032348.j13NmQmo17429278@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16887.1203.470842.161249@napali.hpl.hp.com>
In-Reply-To: <16887.1203.470842.161249@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony Luck wrote:
> 
> Also I noticed that ia64_sal_to_os_handoff_state
> hasn't been replicated ... won't we need that too?

According to the SAL Spec, MCAs are supposed to be handled
one at a time.  

I would like that to change, so that multiple independent
MCAs could be handled in parallel, but that would require
a number of Spec changes (ie the way rendezvous works).

We should go down that path...

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
