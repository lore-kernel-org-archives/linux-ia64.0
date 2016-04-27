From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 27 Apr 2016 11:30:05 +0000
Subject: Re: char: legacy RTC cleanups
Message-Id: <13390963.BOLfm8tOYx@wuerfel>
List-Id: <linux-ia64.vger.kernel.org>
References: <1461707052-1337718-1-git-send-email-arnd@arndb.de> <4937900.aITlOE9vLo@wuerfel> <CAMuHMdW6AODmVwB59uTvMydbTNiDDxQWB3p-Dp9Dka+GVyP_iw@mail.gmail.com>
In-Reply-To: <CAMuHMdW6AODmVwB59uTvMydbTNiDDxQWB3p-Dp9Dka+GVyP_iw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Alexandre Belloni <alexandre.belloni@free-electrons.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Tony Luck <tony.luck@intel.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Rich Felker <dalias@libc.org>, David Howells <dhowells@redhat.com>, Koichi Yasutake <yasutake.koichi@jp.panasonic.com>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, alpha <linux-alpha@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Alessandro Zummo <a.zummo@towertech.it>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Parisc List <linux-parisc@vger.kernel.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>

On Wednesday 27 April 2016 12:19:59 Geert Uytterhoeven wrote:
> >
> > Right, so we could skip patches 5 and 6, and instead remove the two
> > headers as we remove the driver. Let's see what the architecture
> > maintainers think about it, at least powerpc actually enables gen_rtc
> > in its defconfig, so it might take a while to move it over.
> 
> FWIW, all PPC defconfigs (except tqm8xx.dts, which is a more recent platform)
> enabling it did that long before my old commit to enable rtc-generic support
> on PPC:
> 
> commit bcd68a70cb0eee556d86d93133aa150319bd9f53
> Author: Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>
> Date:   Thu Feb 19 16:50:46 2009 +0100
> 
>     powerpc: Hook up rtc-generic, and kill rtc-ppc

Ah, interesting. I have two observations about that patch:

- you were moving basically in the opposite direction that I am
  trying to bring it now. ;-)

- I see now that four defconfigs (gamecube, powernv, pseries and wii)
  do enable RTC_DRV_GENERIC. For some reason, ppc64_defconfig only
  enables RTC_DRV_DS1307, I assume that is not intentional.

	Arnd
