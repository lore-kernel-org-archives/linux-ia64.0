From: Jesse Barnes <jbarnes@sgi.com>
Date: Wed, 14 May 2003 01:24:01 +0000
Subject: Re: [Linux-ia64] Re: [PATCH] head.S fix for unusual load addrs
Message-Id: <marc-linux-ia64-105590723705767@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705550@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705550@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Great!  I'm working on a 2.5.69 SN update now, so hopefully I'll have
a chance to test your patch a little soon.

Thanks,
Jesse

On Tue, May 13, 2003 at 03:18:48PM -0700, Luck, Tony wrote:
> Here's a proof of concept patch (against 2.5.67) that covers
> most of the features we've been talking about in this thread.
> This builds and boots both UP and SMP on a Tiger.
> 
> Kernel text and data are linked into region 5 at address
> 0xA000000100000000, leaving the bottom 4G of region 5 available
> for miscellaneous stuff as suggested by David.  It will be possible
> to extend this patch to split text and data into separate sections
> to allow kernel text replication, but I left that out for now to
> keep this patch to the bare minimum.
> 
> This version still uses the __tpa() macro, but converting it to
> use the ia64_tpa() inline function is just a matter of getting
> all the types (argument and return value) so that the compiler
> doesn't spit warnings all over the screen during build.
> 
> This patch doesn't fixup fs/proc/kcore.c (my old patch didn't
> apply cleanly ... and much of the changes it would have made are
> no longer needed as kernel is now at a lower address than modules).

