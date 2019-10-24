From: Arnd Bergmann <arnd@arndb.de>
Date: Thu, 24 Oct 2019 07:32:35 +0000
Subject: Re: [PATCH 1/2] rtc/ia64: remove legacy efirtc driver
Message-Id: <CAK8P3a2=9dw2YN-sc7yxwwnRi-6Bos32==523qPaqW=avLs60Q@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191023150311.844123-1-arnd@arndb.de> <20191023184616.GA17078@agluck-desk2.amr.corp.intel.com>
 <20191023200135.GT3125@piout.net> <3908561D78D1C84285E8C5FCA982C28F7F4AD7F7@ORSMSX115.amr.corp.intel.com>
 <20191023232004.GV3125@piout.net>
In-Reply-To: <20191023232004.GV3125@piout.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alexandre Belloni <alexandre.belloni@bootlin.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "linux-rtc@vger.kernel.org" <linux-rtc@vger.kernel.org>, Alessandro Zummo <a.zummo@towertech.it>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "Yu, Fenghua" <fenghua.yu@intel.com>, Stephane Eranian <eranian@google.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu, Oct 24, 2019 at 1:20 AM Alexandre Belloni
<alexandre.belloni@bootlin.com> wrote:
>
> On 23/10/2019 21:30:29+0000, Luck, Tony wrote:
> > >> rtc-efi rtc-efi: setting system clock to 2019-10-23T18:30:23 UTC (1571855423)
> >
> > > You can remove CONFIG_RTC_HCTOSYS, this line will disappear, systemd
> > > will not like that but efirtc was not setting the system time anyway so
> > > this shouldn't change the behaviour.
> >
> >
> > Wait ... that message says "setting system clock"
> >
> > but then you say " efirtc was not setting the system time anyway".
> >
> > So did the time get set, or not?
> >
> > If it wasn't set, why does the message say that it was set?
> >
>
> What I meant was that drivers/char/efirtc.c was not setting the system
> time but when using drivers/rtc/rtc-efi.c with CONFIG_RTC_HCTOSYS, the
> kernel will use the rtc to set the system time.

arch/ia64 has a read_persistent_clock64() function, so it ends up reading
the system time regardless of the RTC driver or CONFIG_RTC_HCTOSYS.

As ia64 sets neither ARCH_HIBERNATION_POSSIBLE nor
ARCH_SUSPEND_POSSIBLE, so we could just remove the
read_persistent_clock64() and efi_gettimeofday(), relying instead
on user space (/sbin/hwclock) or CONFIG_RTC_HCTOSYS.

         Arnd
