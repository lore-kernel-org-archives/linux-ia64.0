From: Russ Anderson <rja@sgi.com>
Date: Mon, 04 Oct 2004 00:06:23 +0000
Subject: Re: RFC - freeing up ar.k5
Message-Id: <200410040006.i9406NQo062247@ben.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200409162152.i8GLqwG01566@unix-os.sc.intel.com>
In-Reply-To: <200409162152.i8GLqwG01566@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony Luck wrote:
> 
> This looks like a decision that could be undone without too much
> pain later ... so I'll say "yes", let's use ar.k3 for the physical
> address of the percpu area as a "preliminary decision" ... if it turns
> out to be bad, then I'll admit to being a "nincompoop", and we'll add
> more loops looking for cr.lid in the ia64_mca_tlb_list[] to get ar.k3
> free again.

Great.  Sounds like a plan.

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
