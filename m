From: Helge Deller <deller@gmx.de>
Date: Fri, 30 Oct 2020 19:48:54 +0000
Subject: Re: [PATCH v2 07/15] parisc: use legacy_timer_tick
Message-Id: <b4779fce-5218-8aea-a416-b2806c9d062d@gmx.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20201030151758.1241164-1-arnd@kernel.org>
 <20201030151758.1241164-8-arnd@kernel.org>
 <2e2d7b65-0aa8-55aa-d395-52cfb048adef@gmx.de>
 <CAK8P3a0dPxWu6obX6jca8TsDQw6xsBmrihu8oH0TxR-BxYV3vw@mail.gmail.com>
In-Reply-To: <CAK8P3a0dPxWu6obX6jca8TsDQw6xsBmrihu8oH0TxR-BxYV3vw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@kernel.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Arnd Bergmann <arnd@arndb.de>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Greg Ungerer <gerg@linux-m68k.org>, Finn Thain <fthain@telegraphics.com.au>, Philip Blundell <philb@gnu.org>, Joshua Thompson <funaho@jurai.org>, Sam Creasey <sammy@sammy.net>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Daniel Lezcano <daniel.lezcano@linaro.org>, John Stultz <john.stultz@linaro.org>, Stephen Boyd <sboyd@kernel.org>, Linus Walleij <linus.walleij@linaro.org>, linux-ia64@vger.kernel.org, Parisc List <linux-parisc@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>

On 10/30/20 8:33 PM, Arnd Bergmann wrote:
> On Fri, Oct 30, 2020 at 6:13 PM Helge Deller <deller@gmx.de> wrote:
>>
>> On 10/30/20 4:17 PM, Arnd Bergmann wrote:
>>> From: Arnd Bergmann <arnd@arndb.de>
>>>
>>> parisc has selected CONFIG_GENERIC_CLOCKEVENTS since commit 43b1f6abd590
>>> ("parisc: Switch to generic sched_clock implementation"), but does not
>>> appear to actually be using it, and instead calls the low-level
>>> timekeeping functions directly.
>>
>> Arnd, thank you for this patch!
>> It reminded me that I really missed to fully implement the clockevents on parisc!
>>
>> Your other patch ("RFC: m68k: mac: convert to generic clockevent")
>> was a big help too, as it showed how it might work on parisc as well.
>>
>> Here is now a current version of the clockevents-enabling-patch for parisc:
>> https://git.kernel.org/pub/scm/linux/kernel/git/deller/parisc-linux.git/commit/?h=for-next&id=3b7ab4a74a2d1972dbeb33285d85f1500b2ff96a
>
> Ah, nice!
>
>>> Remove the GENERIC_CLOCKEVENTS select again, and instead convert to
>>> the newly added legacy_timer_tick() helper.
>>
>> My patch still needs more testing, but if it turns to work
>> out right, would you mind to drop your patch for parisc?
>
> I think it would be easier if you could base your patch on top of
> my series, as they would otherwise inevitably conflict. I could either
> add it to my tree, or you could merge my branch into your tree.

Couldn't you drop your patch and include mine in your tree instead?
That way nothing conflicts, and they get merged together?

Helge
