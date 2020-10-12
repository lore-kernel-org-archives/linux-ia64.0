From: Thomas Gleixner <tglx@linutronix.de>
Date: Mon, 12 Oct 2020 20:44:36 +0000
Subject: Re: [PATCH 11/13] timekeeping: remove xtime_update
Message-Id: <87pn5np423.fsf@nanos.tec.linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20201008154651.1901126-1-arnd@arndb.de> <20201008154651.1901126-12-arnd@arndb.de> <CAMuHMdU7bn7rzG-0xzr4St1uArGoOhw6dy7HCkrHRvYqM38Wxg@mail.gmail.com> <CAK8P3a2hY+Vc3S32KKBJj7gUaUFQb4=rKsRJwCwhAbYP7CakzA@mail.gmail.com>
In-Reply-To: <CAK8P3a2hY+Vc3S32KKBJj7gUaUFQb4=rKsRJwCwhAbYP7CakzA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Greg Ungerer <gerg@linux-m68k.org>, Finn Thain <fthain@telegraphics.com.au>, Philip Blundell <philb@gnu.org>, Joshua Thompson <funaho@jurai.org>, Sam Creasey <sammy@sammy.net>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Daniel Lezcano <daniel.lezcano@linaro.org>, John Stultz <john.stultz@linaro.org>, Stephen Boyd <sboyd@kernel.org>, Linus Walleij <linus.walleij@linaro.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Parisc List <linux-parisc@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>

On Mon, Oct 12 2020 at 15:37, Arnd Bergmann wrote:
> On Mon, Oct 12, 2020 at 3:16 PM Geert Uytterhoeven <geert@linux-m68k.org> wrote:
>> On Thu, Oct 8, 2020 at 5:48 PM Arnd Bergmann <arnd@arndb.de> wrote:
>> The comment about xtime_update() in arch/ia64/kernel/time.c needs
>> an update.
>
> I think the correct action for ia64 would be to make it a
> proper clockevent driver with oneshot support, and remove
> the rest of this logic.

Correct action would be to remove all of arch/ia64 :)

> I could try to rewrite the comment, but I tried not to touch that
> part since I don't understand the logic behind it. Maybe the
> ia64 maintainers can comment here why it even tries to skip
> a timer tick. Is there a danger of ending up with the timer irq
> permanently disabled if the timer_interrupt() function returns
> with the itm register in the past, or is this simply about not having
> too many interrupts in a row?

There was a comment in the initial ia64 code:

                * There is a race condition here: to be on the "safe"
                * side, we process timer ticks until itm.next is
                * ahead of the itc by at least half the timer
                * interval.  This should give us enough time to set
                * the new itm value without losing a timer tick.

The ITM (Interval Timer Match) register is raising an interrupt when the
ITM value matches the ITC (Interval Timer Counter) register. If the new
counter is already past the match then the timer interrupt will happen
once ITC wrapped around and reaches the match value again. Might take
ages for a 64bit counter to do that. :)

IIRC, PXA had the same problem and HPET definitely has it as well. Seems
Intel patented the concept of broken timers, but at least they listened
when they proposed to implement the TSC deadline timer on x86 in the
exact same way.

See hpet_clkevt_set_next_event() for the gory details how to handle that
correctly.

Thanks,

        tglx
