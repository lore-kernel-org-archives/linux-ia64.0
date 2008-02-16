From: Andrew Morton <akpm@linux-foundation.org>
Date: Sat, 16 Feb 2008 06:54:59 +0000
Subject: Re: [PATCH] SGI Altix mmtimer - allow larger number of timers per
Message-Id: <20080215225459.ef61448e.akpm@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080207213552.GA2658@sgi.com>
In-Reply-To: <20080207213552.GA2658@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, 9 Feb 2008 15:49:17 -0600 Dimitri Sivanich <sivanich@sgi.com> wrote:

> The purpose of this patch to the SGI Altix specific mmtimer (posix timer)
> driver is to allow a virtually infinite number of timers to be set per node.
> 
> Timers will now be kept on a sorted per-node list and a single node-based
> hardware comparator is used to trigger the next timer.

drivers/char/mmtimer.c: In function `sgi_timer_del':
drivers/char/mmtimer.c:607: warning: 't' might be used uninitialized in this function

Are you sure this is absolutely always a false positive?   If so,
we can shut it up with uninitialized_var().
