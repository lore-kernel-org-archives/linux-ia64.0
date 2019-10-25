From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 25 Oct 2019 10:41:49 +0000
Subject: Re: [PATCH 1/2] rtc/ia64: remove legacy efirtc driver
Message-Id: <CAK8P3a28aRv5TpRn1xhjZFO9n=+CBG6V276Roqm=bE_eQZkw_w@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191023150311.844123-1-arnd@arndb.de> <20191023184616.GA17078@agluck-desk2.amr.corp.intel.com>
 <20191023200135.GT3125@piout.net> <3908561D78D1C84285E8C5FCA982C28F7F4AD7F7@ORSMSX115.amr.corp.intel.com>
 <20191023232004.GV3125@piout.net> <CAK8P3a2=9dw2YN-sc7yxwwnRi-6Bos32==523qPaqW=avLs60Q@mail.gmail.com>
 <3908561D78D1C84285E8C5FCA982C28F7F4AEDED@ORSMSX115.amr.corp.intel.com>
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F7F4AEDED@ORSMSX115.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Alexandre Belloni <alexandre.belloni@bootlin.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "linux-rtc@vger.kernel.org" <linux-rtc@vger.kernel.org>, Alessandro Zummo <a.zummo@towertech.it>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "Yu, Fenghua" <fenghua.yu@intel.com>, Stephane Eranian <eranian@google.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu, Oct 24, 2019 at 6:57 PM Luck, Tony <tony.luck@intel.com> wrote:
>
> > arch/ia64 has a read_persistent_clock64() function, so it ends up reading
> > the system time regardless of the RTC driver or CONFIG_RTC_HCTOSYS.
> >
> > As ia64 sets neither ARCH_HIBERNATION_POSSIBLE nor
> > ARCH_SUSPEND_POSSIBLE, so we could just remove the
> > read_persistent_clock64() and efi_gettimeofday(), relying instead
> > on user space (/sbin/hwclock) or CONFIG_RTC_HCTOSYS.
>
> Seems weird. ia64 has always assumed from day 1 that it is running
> on a UEFI capable platorm (well at day 1 it was called "EFI", the "U"
> came later).
>
> So read_persistent_clock64() just calls EFI directly to get the time.
>
> Seems simpler than worrying about having the right drivers and CONFIG
> bits set.

It would just be a little more consistent. Most architectures cannot
implement  read_persistent_clock64()  or CONFIG_RTC_HCTOSYS
when the RTC driver is a loadable module, so distros normally have to
set the system time after loading modules already. If some architectures
have a reliable platform interface that allows setting the time at early
boot, that doesn't mean we have to rely on that.

       Arnd
