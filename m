From: Andrew Morton <akpm@linux-foundation.org>
Date: Thu, 07 Oct 2010 22:42:56 +0000
Subject: Re: [PATCH] SGI Altix IA64 mmtimer: Eliminate long interval timer
Message-Id: <20101007154256.aedacb62.akpm@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20101007143941.GA10653@sgi.com>
In-Reply-To: <20101007143941.GA10653@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 7 Oct 2010 09:39:41 -0500
Dimitri Sivanich <sivanich@sgi.com> wrote:

> This patch for SGI Altix/IA64 eliminates interval long timer holdoffs in
> cases where we don't start an interval timer before the expiration time.
> This sometimes happens when a number of interval timers on the same shub
> with the same interval run simultaneously.
> 

Grumble.

> --- linux-2.6.orig/drivers/char/mmtimer.c	2010-10-07 09:34:29.837725250 -0500
> +++ linux-2.6/drivers/char/mmtimer.c	2010-10-07 09:34:31.609948769 -0500
> @@ -174,9 +174,8 @@ static void mmtimer_setup_int_2(int cpu,
>   * in order to insure that the setup succeeds in a deterministic time frame.
>   * It will check if the interrupt setup succeeded.
>   */
> -static int mmtimer_setup(int cpu, int comparator, unsigned long expires)
> +static int mmtimer_setup(int cpu, int comparator, unsigned long expires, u64 *r)

Choosing a variable's identifier is your last chance to explain to the
reader what that variable does.  And you blew it!

>  
> ...
>
> +static unsigned mmtimer_intrvl_retry_incr = MMTIMER_INTRVL_RETRY_INCR_DEFAULT;
> +module_param(mmtimer_intrvl_retry_incr, uint, 0644);
> +MODULE_PARM_DESC(mmtimer_intrvl_retry_incr,
> +	"RTC ticks to add to expiration on interval retry (default 40)");

And the problem with abbreviations like "intrvl" is that they're hard
to remember.  Which is why in the kernel we much prefer to use the
entire English word.


I'm unable to work out how important this patch is.  I'm presently
assuming 2.6.37.
