From: Russ Anderson <rja@sgi.com>
Date: Wed, 26 Jan 2005 19:01:32 +0000
Subject: Re: [patch] fix per-CPU MCA mess and make UP kernels work again
Message-Id: <200501261901.j0QJ1WGk12184884@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16887.1203.470842.161249@napali.hpl.hp.com>
In-Reply-To: <16887.1203.470842.161249@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger wrote:
> 
> BTW: can you remind me why you want node-local MCA data?  Performance
> is probably not an issue.  Are you concerned about error-containment,
> hot-swap, or something else?

I'm not aware of a compelling functional reason that the MCA data 
has to be node-local.  The key feature is that each CPU have a unique
MCA data area.  If all the MCA data areas are on one node, that
should be OK.  If a CPU cannot access MCA data memory on a remote 
node, odds are we will die anyway.

It seems logical to me that MCA data be close to the node/cpu using
it, but workable if it is not.

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
