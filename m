From: Grant Grundler <grundler@cup.hp.com>
Date: Wed, 25 Sep 2002 20:45:21 +0000
Subject: Re: [Linux-ia64] platform detection at run-time
Message-Id: <marc-linux-ia64-105590701906065@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701906051@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701906051@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Sane_Purushottam@emc.com wrote:
> The reason, I have to detect the architecture at run time has to do with the
> interface with (sg) driver. Since the driver is natively compiled for
> 64-bit, it expects the data structure handed over to it, to be 64-bit wide.
> Thus my 32-bit application cannot issue ioctl calls successfully.

isn't "arch/*/kernel/ioctl32.c" the place to handle this kind of conversion?

grundler <514>fgrep SG arch/parisc/kernel/ioctl32.c
COMPATIBLE_IOCTL(FDMSGON)
COMPATIBLE_IOCTL(FDMSGOFF)
COMPATIBLE_IOCTL(FDSETEMSGTRESH)
/* SG stuff */
COMPATIBLE_IOCTL(SG_SET_TIMEOUT)
COMPATIBLE_IOCTL(SG_GET_TIMEOUT)
COMPATIBLE_IOCTL(SG_EMULATED_HOST)
COMPATIBLE_IOCTL(SG_SET_TRANSFORM)
...


ia64 seems to drop this kind of thing in arch/ia64/ia32/ia32_ioctl.c

> So, in my application, based on the platform, I fill the appropriate
> structure before ioctl call.

putting it in the application sounds like the wrong thing to do.

grant

