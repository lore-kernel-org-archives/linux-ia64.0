From: Grant Grundler <iod00d@hp.com>
Date: Fri, 27 Aug 2004 22:48:49 +0000
Subject: Re: high resolution timer on ia64
Message-Id: <20040827224849.GB960@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <082720042204.7248.412FAFEE0005A00000001C502200735834040104040E05@comcast.net>
In-Reply-To: <082720042204.7248.412FAFEE0005A00000001C502200735834040104040E05@comcast.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Aug 27, 2004 at 03:26:52PM -0700, Grant Grundler wrote:
> Does CONFIG_HPET cover what you need?
> That's already included in the 2.6.8.1 kernels.

Looks like I spoke too soon...

grant

...
  CC      drivers/char/hpet.o
drivers/char/hpet.c:669: error: `MC' undeclared here (not in a function)
drivers/char/hpet.c:669: error: initializer element is not constant
drivers/char/hpet.c:669: error: (near initialization for `hpet_interpolator.addr')
drivers/char/hpet.c: In function `hpet_init':
drivers/char/hpet.c:944: error: `hpet_cycles_per_sec' undeclared (first use in this function)
drivers/char/hpet.c:944: error: (Each undeclared identifier is reported only once
drivers/char/hpet.c:944: error: for each function it appears in.)
drivers/char/hpet.c:948: error: `hpet_nsecs_per_cycle' undeclared (first use in this function)
make[2]: *** [drivers/char/hpet.o] Error 1
make[1]: *** [drivers/char] Error 2
make: *** [drivers] Error 2
grundler@gsyprf3:/usr/src/linux-ia64-test-2.6.8.1$ 
