From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 27 Apr 2016 11:35:30 +0000
Subject: Re: [PATCH 6/8] char/genrtc: parisc: use asm-generic/rtc.h
Message-Id: <4599222.az1Zyv5Lrl@wuerfel>
List-Id: <linux-ia64.vger.kernel.org>
References: <1461707052-1337718-1-git-send-email-arnd@arndb.de> <3034953.EvqV1iv2Ef@caliban.sf-tec.de> <18012781.hPTzXnRcSP@wuerfel>
In-Reply-To: <18012781.hPTzXnRcSP@wuerfel>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Rolf Eike Beer <eike-kernel@sf-tec.de>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, tony.luck@intel.com, geert@linux-m68k.org, jejb@parisc-linux.org, deller@gmx.de, benh@kernel.crashing.org, mpe@ellerman.id.au, dalias@libc.org, dhowells@redhat.com, yasutake.koichi@jp.panasonic.com, rth@twiddle.net, ink@jurassic.park.msu.ru, linux-alpha@vger.kernel.org, x86@kernel.org, a.zummo@towertech.it, alexandre.belloni@free-electrons.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, rtc-linux@googlegroups.com, linux-arch@vger.kernel.org

On Wednesday 27 April 2016 13:21:16 Arnd Bergmann wrote:
> On Wednesday 27 April 2016 00:07:47 Rolf Eike Beer wrote:
> > Arnd Bergmann wrote:
> > > The asm-generic/rtc.h header can now be included by
> > > architectures that provide their own set_rtc_time/get_rtc_time
> > > macros, letting us remove most of the common contents in
> > > the powerpc implementation.
> > 
> > parisc in this case.
> > 
> 
> Fixed, thanks!

Actually, after the comment about just removing the gen_rtc driver
in the long run, I checked again and found that PARISC unconditionally
selects RTC_CLASS, so this driver can't even be built here.
We should just remove the header and drop PARISC from the list.

If we also drop m68k, that just leaves powerpc.

	Arnd
