From: Jesse Barnes <jbarnes@sgi.com>
Date: Thu, 25 Apr 2002 01:22:14 +0000
Subject: [Linux-ia64] Re: PCI DAC routines for SN
Message-Id: <marc-linux-ia64-105590701905526@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905493@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905493@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Apr 24, 2002 at 06:00:23PM -0700, David S. Miller wrote:
> The DMA api is confusing enough, and you want to add yet another
> interface for device driver author Joe Blow to have to learn?

What if it's just a simple flag (or mask like dma_mask) that the
driver optionally sets to true (or 64 bits)?  That way, the drivers
wouldn't have to change at all and the default behaviour would be
identical to the current API?

Of course, this only make sense if you acknowledge that (2) is at
least of some small concern (small, simple fix for a small, simple
problem).

> This basically boils down to the fact that it must do one of two
> things:
> 
> 1) It must make performance phenominally better.
> 
>    In the DAC consistent case, it actaully will decrease bus
>    utilization slightly, we agree on this.
> 
> 2) It must make some DMA performance optimization possible which
>    currently is not possible at all.
> 
>    I do not believe this is the case.  You've tried to argue that
>    SAC consistent memory is precious for mappings, and I've tried
>    to show you that the consistent part of the mappings used by
>    devices won't even show up on the radar.
> 
> We are at an impasse' and I really doubt this is going to change.
> All you can do by arguing further is just make me type the same
> things a few more times, and I'd like to avoid that, I type enough
> already. :-)

I know the feeling.  At any rate, thanks for the lively discussion.
It's been educational.

Jesse

