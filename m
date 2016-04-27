From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Wed, 27 Apr 2016 10:19:59 +0000
Subject: Re: char: legacy RTC cleanups
Message-Id: <CAMuHMdW6AODmVwB59uTvMydbTNiDDxQWB3p-Dp9Dka+GVyP_iw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1461707052-1337718-1-git-send-email-arnd@arndb.de>
	<20160427094410.GJ3264@piout.net>
	<4937900.aITlOE9vLo@wuerfel>
In-Reply-To: <4937900.aITlOE9vLo@wuerfel>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: Alexandre Belloni <alexandre.belloni@free-electrons.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Tony Luck <tony.luck@intel.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Rich Felker <dalias@libc.org>, David Howells <dhowells@redhat.com>, Koichi Yasutake <yasutake.koichi@jp.panasonic.com>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, alpha <linux-alpha@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Alessandro Zummo <a.zummo@towertech.it>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Parisc List <linux-parisc@vger.kernel.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, Linux-sh

Hi Arnd,

On Wed, Apr 27, 2016 at 12:07 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> On Wednesday 27 April 2016 11:44:10 Alexandre Belloni wrote:
>> On 26/04/2016 at 23:44:04 +0200, Arnd Bergmann wrote :
>> > I've had these patches in my tree for a while, after the first one
>> > had a few issues that are fixed in this new version. The old-style
>> > PC RTC driver is now also disabled on m68k (as pointed out by
>> > Geert), ppc (it was also blacklisted), and m32r (I showed that
>> > it did not build).
>> >
>> > For the genrtc driver, rearranging the headers makes it simpler
>> > to use and reduces duplication. In case of alpha and mn10300,
>> > I've shown that the genrtc and rtc drivers are doing the same
>> > thing, so we don't need them both. The remaining three
>> > architectures (m68k, parisc, powerpc) actually all support
>> > the newer rtc-generic driver, so we could remove genrtc completely
>> > if we want to.
>> >
>>
>> Personally, I'd go for the kill and remove genrtc instead of cleaning it up.
>
> Right, so we could skip patches 5 and 6, and instead remove the two
> headers as we remove the driver. Let's see what the architecture
> maintainers think about it, at least powerpc actually enables gen_rtc
> in its defconfig, so it might take a while to move it over.

FWIW, all PPC defconfigs (except tqm8xx.dts, which is a more recent platform)
enabling it did that long before my old commit to enable rtc-generic support
on PPC:

commit bcd68a70cb0eee556d86d93133aa150319bd9f53
Author: Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>
Date:   Thu Feb 19 16:50:46 2009 +0100

    powerpc: Hook up rtc-generic, and kill rtc-ppc

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
