From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 09 Oct 2000 16:02:53 +0000
Subject: Re: [Linux-ia64] avoiding float underflow software assist
Message-Id: <marc-linux-ia64-105590678205559@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205556@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205556@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 9 Oct 2000 17:37:35 +0200 (MET DST), Dan Pop <Dan.Pop@cern.ch> said:

  Dan> #include <asm/fpu.h>

Please don't do this.  Applications must not include Linux kernel
header files.

The correct way of doing this is to do:

	#include <fenv.h>

	fesetenv (FE_NONIEEE_ENV);

or to compile with -ffast-math.  For the former to work, you need
glibc-2.2.  For the latter, you need both glibc-2.2 and some mods to
the compiler (which probably don't exist yet).

If you want to avoid the those complications, you can turn off
flush-to-zero mode with the following hack:

        asm volatile ("mov ar.fpsr=%0" :: "r"(0x9804c0270037f));

It's only a hack, but it should do for now.

	--david

