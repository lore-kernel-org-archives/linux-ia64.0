From: Dimitri Sivanich <sivanich@sgi.com>
Date: Mon, 25 Feb 2008 18:33:26 +0000
Subject: Re: [PATCH] SGI Altix mmtimer - allow larger number of timers per node
Message-Id: <20080225183326.GC9350@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080207213552.GA2658@sgi.com>
In-Reply-To: <20080207213552.GA2658@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Feb 15, 2008 at 10:54:59PM -0800, Andrew Morton wrote:
> 
> drivers/char/mmtimer.c: In function `sgi_timer_del':
> drivers/char/mmtimer.c:607: warning: 't' might be used uninitialized in this function
> 
> Are you sure this is absolutely always a false positive?   If so,
> we can shut it up with uninitialized_var().

Only 2 ways 't' wouldn't be set at all:
  - If 'n' was NULL right away at line 613.  We then exit immediatly at line 626.

  - If we never found 't->timer = timr', in which case we made it to the end of a branch, and once again 'n' would be NULL and would exit right away at line 626.

So yes, I'm in agreement with your patch to shut it up with uninitialized_var().
