From: Jason Uhlenkott <jasonuhl@sgi.com>
Date: Tue, 16 Aug 2005 21:11:30 +0000
Subject: Re: [PATCH] Make sched_clock() work in early boot
Message-Id: <20050816211130.GC753838@dragonfly.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050816195916.GA753838@dragonfly.engr.sgi.com>
In-Reply-To: <20050816195916.GA753838@dragonfly.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Aug 16, 2005 at 01:56:10PM -0700, Luck, Tony wrote:
> Also interesting is that even with your fix, there is something
> wrong with the code ... the first few lines of output are lost
> output starts with:
> 
>  of memory at 0x85000 due to granule hole at 0x0
> [   0.000000] efi.trim_bottom: ignoring ...

That's odd.  I'm getting full output on sn2 (on both real hardware and
medusa).


> Finally, while your patch is compact and neat, I have to agree
> with David that depending on the locked TR entry for the per-cpu
> area is an assumption that I'd prefer not to hardwire into more
> places.

I don't necessarily disagree.  Using a speculative load for this seemed
a little sleazy to me.  I just didn't know of any other cheap way to
test for the existence of the per-cpu area...
