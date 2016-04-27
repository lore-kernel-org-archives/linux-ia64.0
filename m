From: Alexandre Belloni <alexandre.belloni@free-electrons.com>
Date: Wed, 27 Apr 2016 09:44:10 +0000
Subject: Re: char: legacy RTC cleanups
Message-Id: <20160427094410.GJ3264@piout.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1461707052-1337718-1-git-send-email-arnd@arndb.de>
In-Reply-To: <1461707052-1337718-1-git-send-email-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, tony.luck@intel.com, geert@linux-m68k.org, jejb@parisc-linux.org, deller@gmx.de, benh@kernel.crashing.org, mpe@ellerman.id.au, dalias@libc.org, dhowells@redhat.com, yasutake.koichi@jp.panasonic.com, rth@twiddle.net, ink@jurassic.park.msu.ru, linux-alpha@vger.kernel.org, x86@kernel.org, a.zummo@towertech.it, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, rtc-linux@googlegroups.com, linux-arch@vger.kernel.org

On 26/04/2016 at 23:44:04 +0200, Arnd Bergmann wrote :
> I've had these patches in my tree for a while, after the first one
> had a few issues that are fixed in this new version. The old-style
> PC RTC driver is now also disabled on m68k (as pointed out by
> Geert), ppc (it was also blacklisted), and m32r (I showed that
> it did not build).
> 
> For the genrtc driver, rearranging the headers makes it simpler
> to use and reduces duplication. In case of alpha and mn10300,
> I've shown that the genrtc and rtc drivers are doing the same
> thing, so we don't need them both. The remaining three
> architectures (m68k, parisc, powerpc) actually all support
> the newer rtc-generic driver, so we could remove genrtc completely
> if we want to.
> 

Personally, I'd go for the kill and remove genrtc instead of cleaning it
up.

-- 
Alexandre Belloni, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
