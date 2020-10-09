From: Finn Thain <fthain@telegraphics.com.au>
Date: Fri, 09 Oct 2020 22:18:53 +0000
Subject: Re: [PATCH 01/13] timekeeping: add CONFIG_LEGACY_TIMER_TICK
Message-Id: <alpine.LNX.2.23.453.2010100820110.12@nippy.intranet>
List-Id: <linux-ia64.vger.kernel.org>
References: <20201008154651.1901126-1-arnd@arndb.de> <20201008154651.1901126-2-arnd@arndb.de>
In-Reply-To: <20201008154651.1901126-2-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: linux-kernel@vger.kernel.org, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Greg Ungerer <gerg@linux-m68k.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Philip Blundell <philb@gnu.org>, Joshua Thompson <funaho@jurai.org>, Sam Creasey <sammy@sammy.net>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Thomas Gleixner <tglx@linutronix.de>, Daniel Lezcano <daniel.lezcano@linaro.org>, John Stultz <john.stultz@linaro.org>, Stephen Boyd <sboyd@kernel.org>, Linus Walleij <linus.walleij@linaro.org>, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-arm-kernel@lists.infradead.org

Hi Arnd,

On Thu, 8 Oct 2020, Arnd Bergmann wrote:

> All platforms that currently do not use generic clockevents roughly call
> the same set of functions in their timer interrupts: xtime_update(),
> update_process_times() and profile_tick(), sometimes in a different
> sequence.
> 
> Add a helper function that performs all three of them, to make the
> callers more uniform and simplify the interface.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
>  include/linux/timekeeping.h |  1 +
>  kernel/time/Kconfig         |  7 +++++++
>  kernel/time/Makefile        |  1 +
>  kernel/time/tick-legacy.c   | 19 +++++++++++++++++++
>  4 files changed, 28 insertions(+)
>  create mode 100644 kernel/time/tick-legacy.c
> 
> diff --git a/include/linux/timekeeping.h b/include/linux/timekeeping.h
> index 7f7e4a3f4394..3670cb1670ff 100644
> --- a/include/linux/timekeeping.h
> +++ b/include/linux/timekeeping.h
> @@ -12,6 +12,7 @@ extern int timekeeping_suspended;
>  /* Architecture timer tick functions: */
>  extern void update_process_times(int user);
>  extern void xtime_update(unsigned long ticks);
> +extern void legacy_timer_tick(unsigned long ticks);
>  
>  /*
>   * Get and set timeofday
> diff --git a/kernel/time/Kconfig b/kernel/time/Kconfig
> index a09b1d61df6a..f2b0cfeade47 100644
> --- a/kernel/time/Kconfig
> +++ b/kernel/time/Kconfig
> @@ -61,6 +61,13 @@ config POSIX_CPU_TIMERS_TASK_WORK
>  	bool
>  	default y if POSIX_TIMERS && HAVE_POSIX_CPU_TIMERS_TASK_WORK
>  
> +config LEGACY_TIMER_TICK
> +	bool
> +	help
> +	  The legacy timer tick helper is used by platforms that
> +	  lack support for the generic clockevent framework.
> +	  New platforms should use generic clockevents instead.
> +
>  if GENERIC_CLOCKEVENTS
>  menu "Timers subsystem"
>  
> diff --git a/kernel/time/Makefile b/kernel/time/Makefile
> index c8f00168afe8..1fb1c1ef6a19 100644
> --- a/kernel/time/Makefile
> +++ b/kernel/time/Makefile
> @@ -16,6 +16,7 @@ ifeq ($(CONFIG_GENERIC_CLOCKEVENTS_BROADCAST),y)
>  endif
>  obj-$(CONFIG_GENERIC_SCHED_CLOCK)		+= sched_clock.o
>  obj-$(CONFIG_TICK_ONESHOT)			+= tick-oneshot.o tick-sched.o
> +obj-$(CONFIG_LEGACY_TIMER_TICK)			+= tick-legacy.o
>  obj-$(CONFIG_HAVE_GENERIC_VDSO)			+= vsyscall.o
>  obj-$(CONFIG_DEBUG_FS)				+= timekeeping_debug.o
>  obj-$(CONFIG_TEST_UDELAY)			+= test_udelay.o
> diff --git a/kernel/time/tick-legacy.c b/kernel/time/tick-legacy.c
> new file mode 100644
> index 000000000000..73c5a0af4743
> --- /dev/null
> +++ b/kernel/time/tick-legacy.c
> @@ -0,0 +1,19 @@
> +// SPDX-License-Identifier: GPL-2.0
> +/*
> + * Timer tick function for architectures that lack generic clockevents,
> + * consolidated here from m68k/ia64/parisc/arm.
> + */
> +
> +#include <linux/irq.h>
> +#include <linux/profile.h>
> +#include <linux/timekeeper_internal.h>
> +
> +#include "tick-internal.h"
> +
> +void legacy_timer_tick(unsigned long ticks)
> +{
> +	if (ticks)
> +		xtime_update(ticks);
> +	update_process_times(user_mode(get_irq_regs()));
> +	profile_tick(CPU_PROFILING);
> +}
> 

It's good to see this code refactored in this way because, as well as 
de-duplication, it reveals the logic that's common to the relevant 
platforms and may shed some light on the need for that logic.

Yet it's not clear to me that the clockevents framework is able to replace 
that logic on all of the affected hardware. I suppose it remains to be 
seen.

I hate to quibble about naming, but you seem to be using "legacy" here to 
mean "deprecated" (?) Is it a good idea to prepend such adjectives to 
symbol names?

IMO, the term "legacy" is redundant in this context. That term covers a 
large portion of kernel code, a large number of hardware features in 
current silicon, a large portion of the userspace ABI, a large number of 
production Linux systems, probably all "Unix" systems, etc.

As a corollary, cutting edge ("non-legacy") code is often kept out of open 
source projects by the owners of the intellectual property rights.
