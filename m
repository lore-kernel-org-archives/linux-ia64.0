From: Russ Anderson <rja@sgi.com>
Date: Fri, 28 Jan 2005 22:54:12 +0000
Subject: Re: [patch] fix per-CPU MCA mess and make UP kernels work again
Message-Id: <200501282254.j0SMsDMO14342426@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16887.1203.470842.161249@napali.hpl.hp.com>
In-Reply-To: <16887.1203.470842.161249@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony Luck wrote:
> 
> >OK, how about this patch?  Compile-tested and boot-tested for zx1 UP
> >and SMP and GENERIC.  I also verified that INIT dumps works for all
> >three kernels.
> >
> >The discontig stuff is untested but I hope I got it right.
> 
> Russ ... Jesse ... can you ack when you test this.

The system does not seem to recover as often with this patch, but
I'm not sure why.  At first I thought it may be just reasonable
varience, but after backing out the patch and re-running more times,
then re-applying and re-re-running, it certainly looks like the
test fails quicker with the patch.

When it fails, it Oops's with an ip of 0, as if something was
not restored properly.  But I have to dig deeper to find out 
what is going on.

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
