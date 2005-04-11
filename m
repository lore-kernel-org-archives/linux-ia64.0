From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Mon, 11 Apr 2005 23:13:29 +0000
Subject: Re: [PATCH] make CONFIG_IA64_GENERIC=y && CONFIG_SMP=n work
Message-Id: <200504111613.29815.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504111238.53982.jbarnes@engr.sgi.com>
In-Reply-To: <200504111238.53982.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Monday, April 11, 2005 3:58 pm, Christoph Lameter wrote:
> On Mon, 11 Apr 2005, Jesse Barnes wrote:
> > P.S. I didn't include the fix for mmtimer.c && CONFIG_SMP=n here,
> > Christoph can you fix it?
> > drivers/char/mmtimer.c: In function `mmtimer_tasklet':
> > drivers/char/mmtimer.c:488: error: structure has no member named
> > `write_lock'
>
> I thought this was already fixed by another patchset? But here it is
> again:

It might be, I didn't check -mm.  Please make sure it gets upstream if it 
hasn't already.

Thanks,
Jesse
