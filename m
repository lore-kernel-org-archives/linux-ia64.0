From: Linus Walleij <linus.walleij@linaro.org>
Date: Tue, 12 Sep 2017 14:17:39 +0000
Subject: Re: [PATCH] [RFC] clocksource: improve GENERIC_CLOCKEVENTS dependency
Message-Id: <CACRpkdZwhLgtg1zH3xxo00rC3cN9URDvk+sHqjAsZ9oYgJ73fA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170905150504.1720954-1-arnd@arndb.de> <CACRpkdbruKbL-Qe6P7rCGwxbprFt5rBWF7-eYpuaVPK7fjhkGA@mail.gmail.com>
 <20170912091012.GD20805@n2100.armlinux.org.uk>
In-Reply-To: <20170912091012.GD20805@n2100.armlinux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Cc: Arnd Bergmann <arnd@arndb.de>, Daniel Lezcano <daniel.lezcano@linaro.org>, Thomas Gleixner <tglx@linutronix.de>, Randy Dunlap <rdunlap@infradead.org>, Geert Uytterhoeven <geert@linux-m68k.org>, "linux-m68k@lists.linux-m68k.org" <linux-m68k@vger.kernel.org>, linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Ding Tianhong <dingtianhong@huawei.com>, Mark Rutland <mark.rutland@arm.com>, Marc Zyngier <marc.zyngier@arm.com>, Vineet Gupta <vgupta@synopsys.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, Sep 12, 2017 at 11:10 AM, Russell King - ARM Linux
<linux@armlinux.org.uk> wrote:
> On Tue, Sep 12, 2017 at 10:09:51AM +0200, Linus Walleij wrote:
>> For ARM we now have two subarchs not using generic clockevents:
>> RISC PC and EBSA110.
>>
>> I think Russell stated these two cannot be converted to generic clockevents
>> because of hardware limitations I guess, no timer interrupt, simply, which
>> means no clockevents, or unreliable or not granular enough timers.
>>
>> IIUC the SA110 does not contain the built-in SoC goodies of the SA1100
>> so it needs external timer blocks, and those two machines don't have
>> good enough timers.
>
> That's hardly surprising because SA1100 is a SoC, SA110 is just a CPU,
> containing no peripherals at all.
>
> EBSA110 only has one usable timer, which must be programmed to produce
> a regular timer tick to the OS: it's no good trying to double up the
> clocksource and a periodic clockevent onto one counter register - the
> clock source will see the same timer value +/- interrupt latency, and
> in any case it won't wrap in a power-of-2 manner.
>
> This breaks the assumptions behind the clocksource and timekeeping
> code, which are that we have a timer that wraps in a power-of-2
> manner, and which takes much longer than the desired period to wrap.

Aha, that makes perfect sense. Now I finally understand the exact nature
of this problem.

> I think RiscPC may be convertable as there are two timers, and I think
> the second timer is unused (so could be programmed to the requirements
> of a clocksource) but is there much reason to bother given the EBSA110?
> I think there isn't.

The one reason I've seen is that converting to generic clockevents
often makes it simple to also introduce a delay timer at the same time
by just reusing the clocksource timer for it, and that saves the boot-time
loop calibration. (The MOXA ART and Aspeed saw this when I unified
the Faraday timers.)

But in general no.

Yours,
Linus Walleij
