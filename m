From: Thomas Gleixner <tglx@linutronix.de>
Date: Wed, 27 Apr 2016 10:05:23 +0000
Subject: Re: [PATCH 2/8] char/rtc: legacy RTC is no longer supported on x86
Message-Id: <alpine.DEB.2.11.1604271205100.3941@nanos>
List-Id: <linux-ia64.vger.kernel.org>
References: <1461707052-1337718-1-git-send-email-arnd@arndb.de> <1461707052-1337718-3-git-send-email-arnd@arndb.de>
In-Reply-To: <1461707052-1337718-3-git-send-email-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, tony.luck@intel.com, geert@linux-m68k.org, jejb@parisc-linux.org, deller@gmx.de, benh@kernel.crashing.org, mpe@ellerman.id.au, dalias@libc.org, dhowells@redhat.com, yasutake.koichi@jp.panasonic.com, rth@twiddle.net, ink@jurassic.park.msu.ru, linux-alpha@vger.kernel.org, x86@kernel.org, a.zummo@towertech.it, alexandre.belloni@free-electrons.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, rtc-linux@googlegroups.com, linux-arch@vger.kernel.org

On Tue, 26 Apr 2016, Arnd Bergmann wrote:

> Commit 3195ef59cb42 ("x86: Do full rtc synchronization with ntp") had
> the side-effect of unconditionally enabling the RTC_LIB symbol on x86,
> which in turn disables the selection of the CONFIG_RTC and
> CONFIG_GEN_RTC drivers that contain a two older implementations of
> the CONFIG_RTC_DRV_CMOS driver.
> 
> This removes x86 from the list.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
