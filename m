From: Dan Pop <Dan.Pop@cern.ch>
Date: Mon, 09 Oct 2000 17:21:01 +0000
Subject: Re: [Linux-ia64] avoiding float underflow software assist
Message-Id: <marc-linux-ia64-105590678205562@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205556@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205556@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Mon, 9 Oct 2000, David Mosberger wrote:

> >>>>> On Mon, 9 Oct 2000 17:37:35 +0200 (MET DST), Dan Pop <Dan.Pop@cern.ch> said:
> 
>   Dan> #include <asm/fpu.h>
> 
> Please don't do this.  Applications must not include Linux kernel
> header files.

I know.  I wrote it as a quick and dirty hack for Sverre, because no
other option was available at the time.

> The correct way of doing this is to do:
> 
> 	#include <fenv.h>
> 
> 	fesetenv (FE_NONIEEE_ENV);

I know that, too, but, between the above hack that worked and the
correct solution that was not (yet) implemented, the choice was
obvious :-)

> or to compile with -ffast-math.  For the former to work, you need
> glibc-2.2.  For the latter, you need both glibc-2.2 and some mods to
> the compiler (which probably don't exist yet).

In other words, neither of the correct solutions is available with the
current distributions :-)

> If you want to avoid the those complications, you can turn off
> flush-to-zero mode with the following hack:
> 
>         asm volatile ("mov ar.fpsr=%0" :: "r"(0x9804c0270037f));
> 
> It's only a hack, but it should do for now.

As a hack, it's even worse than mine :-)

Dan


