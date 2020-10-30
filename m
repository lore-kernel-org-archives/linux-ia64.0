From: Helge Deller <deller@gmx.de>
Date: Fri, 30 Oct 2020 17:13:04 +0000
Subject: Re: [PATCH v2 07/15] parisc: use legacy_timer_tick
Message-Id: <2e2d7b65-0aa8-55aa-d395-52cfb048adef@gmx.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20201030151758.1241164-1-arnd@kernel.org>
 <20201030151758.1241164-8-arnd@kernel.org>
In-Reply-To: <20201030151758.1241164-8-arnd@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@kernel.org>, linux-kernel@vger.kernel.org
Cc: Thomas Gleixner <tglx@linutronix.de>, Arnd Bergmann <arnd@arndb.de>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Greg Ungerer <gerg@linux-m68k.org>, Finn Thain <fthain@telegraphics.com.au>, Philip Blundell <philb@gnu.org>, Joshua Thompson <funaho@jurai.org>, Sam Creasey <sammy@sammy.net>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Daniel Lezcano <daniel.lezcano@linaro.org>, John Stultz <john.stultz@linaro.org>, Stephen Boyd <sboyd@kernel.org>, Linus Walleij <linus.walleij@linaro.org>, linux-ia64@vger.kernel.org, Parisc List <linux-parisc@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>

On 10/30/20 4:17 PM, Arnd Bergmann wrote:
> From: Arnd Bergmann <arnd@arndb.de>
>
> parisc has selected CONFIG_GENERIC_CLOCKEVENTS since commit 43b1f6abd590
> ("parisc: Switch to generic sched_clock implementation"), but does not
> appear to actually be using it, and instead calls the low-level
> timekeeping functions directly.

Arnd, thank you for this patch!
It reminded me that I really missed to fully implement the clockevents on parisc!

Your other patch ("RFC: m68k: mac: convert to generic clockevent")
was a big help too, as it showed how it might work on parisc as well.

Here is now a current version of the clockevents-enabling-patch for parisc:
https://git.kernel.org/pub/scm/linux/kernel/git/deller/parisc-linux.git/commit/?h=for-next&id=3b7ab4a74a2d1972dbeb33285d85f1500b2ff96a

> Remove the GENERIC_CLOCKEVENTS select again, and instead convert to
> the newly added legacy_timer_tick() helper.

My patch still needs more testing, but if it turns to work
out right, would you mind to drop your patch for parisc?

Helge


> Reviewed-by: Linus Walleij <linus.walleij@linaro.org>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
>  Documentation/features/time/clockevents/arch-support.txt | 2 +-
>  arch/parisc/Kconfig                                      | 2 +-
>  arch/parisc/kernel/time.c                                | 9 +++------
>  3 files changed, 5 insertions(+), 8 deletions(-)
>
> diff --git a/Documentation/features/time/clockevents/arch-support.txt b/Documentation/features/time/clockevents/arch-support.txt
> index 8287b6aa522e..61a5c9d68c15 100644
> --- a/Documentation/features/time/clockevents/arch-support.txt
> +++ b/Documentation/features/time/clockevents/arch-support.txt
> @@ -21,7 +21,7 @@
>      |       nds32: |  ok  |
>      |       nios2: |  ok  |
>      |    openrisc: |  ok  |
> -    |      parisc: |  ok  |
> +    |      parisc: | TODO |
>      |     powerpc: |  ok  |
>      |       riscv: |  ok  |
>      |        s390: |  ok  |
> diff --git a/arch/parisc/Kconfig b/arch/parisc/Kconfig
> index b234e8154cbd..78b17621ee4a 100644
> --- a/arch/parisc/Kconfig
> +++ b/arch/parisc/Kconfig
> @@ -52,7 +52,7 @@ config PARISC
>  	select HAVE_REGS_AND_STACK_ACCESS_API
>  	select GENERIC_SCHED_CLOCK
>  	select HAVE_UNSTABLE_SCHED_CLOCK if SMP
> -	select GENERIC_CLOCKEVENTS
> +	select LEGACY_TIMER_TICK
>  	select CPU_NO_EFFICIENT_FFS
>  	select NEED_DMA_MAP_STATE
>  	select NEED_SG_DMA_LENGTH
> diff --git a/arch/parisc/kernel/time.c b/arch/parisc/kernel/time.c
> index 13d94f0f94a0..08e4d480abe1 100644
> --- a/arch/parisc/kernel/time.c
> +++ b/arch/parisc/kernel/time.c
> @@ -70,8 +70,6 @@ irqreturn_t __irq_entry timer_interrupt(int irq, void *dev_id)
>  	/* gcc can optimize for "read-only" case with a local clocktick */
>  	unsigned long cpt = clocktick;
>
> -	profile_tick(CPU_PROFILING);
> -
>  	/* Initialize next_tick to the old expected tick time. */
>  	next_tick = cpuinfo->it_value;
>
> @@ -86,10 +84,9 @@ irqreturn_t __irq_entry timer_interrupt(int irq, void *dev_id)
>  	cpuinfo->it_value = next_tick;
>
>  	/* Go do system house keeping. */
> -	if (cpu == 0)
> -		xtime_update(ticks_elapsed);
> -
> -	update_process_times(user_mode(get_irq_regs()));
> +	if (cpu != 0)
> +		ticks_elapsed = 0;
> +	legacy_timer_tick(ticks_elapsed);
>
>  	/* Skip clockticks on purpose if we know we would miss those.
>  	 * The new CR16 must be "later" than current CR16 otherwise
>
