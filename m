From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Fri, 18 Dec 2020 22:32:24 +0000
Subject: Re: [PATCH v2 05/15] ia64: convert to legacy_timer_tick
Message-Id: <7df57999-40dc-507a-acba-605a4057c83e@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20201030151758.1241164-1-arnd@kernel.org>
 <20201030151758.1241164-6-arnd@kernel.org>
 <59efce0e-a28d-9424-82ca-fb7f3a1b9c29@physik.fu-berlin.de>
 <CAK8P3a0s5Wt=9sZXAV1JzebZFXVy4qn3KNvygEfPeH3eVMyO_w@mail.gmail.com>
 <ccc941a9-9b7f-2a37-664e-c01d60c200da@physik.fu-berlin.de>
In-Reply-To: <ccc941a9-9b7f-2a37-664e-c01d60c200da@physik.fu-berlin.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@kernel.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Arnd Bergmann <arnd@arndb.de>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Greg Ungerer <gerg@linux-m68k.org>, Finn Thain <fthain@telegraphics.com.au>, Philip Blundell <philb@gnu.org>, Joshua Thompson <funaho@jurai.org>, Sam Creasey <sammy@sammy.net>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Daniel Lezcano <daniel.lezcano@linaro.org>, John Stultz <john.stultz@linaro.org>, Stephen Boyd <sboyd@kernel.org>, Linus Walleij <linus.walleij@linaro.org>, linux-ia64@vger.kernel.org, Parisc List <linux-parisc@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Mike Rapoport <rppt@linux.ibm.com>, Anatoly Pugachev <matorola@gmail.com>

Hi Arnd!

On 12/18/20 11:13 PM, John Paul Adrian Glaubitz wrote:
>> I've attached a patch for a partial revert of my original change, this
>> should still work with the final cleanup on top, but restore the loop
>> plus the local_irq_enable()/local_irq_disable() that I dropped from
>> the original code. Does this make a difference?
> 
> I'll give it a try and report back.

Yes. That solves the timer issues. Now there is unfortunately still a
second, unrelated regression with the hpsa driver that was introduced
by one of the ia64 patches in the mm tree from Andrew which makes the
hpsa driver not load at all.

Haven't figured out yet what the problem is.

Adrian

-- 
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer - glaubitz@debian.org
`. `'   Freie Universitaet Berlin - glaubitz@physik.fu-berlin.de
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913
