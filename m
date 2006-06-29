From: "Albert Cahalan" <acahalan@gmail.com>
Date: Thu, 29 Jun 2006 14:09:54 +0000
Subject: Re: [PATCH] ia64: change usermode HZ to 250
Message-Id: <787b0d920606290709k255c6c24k6d3dd502d85bd1ca@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060627220139.3168.69409.sendpatchset@tomahawk.engr.sgi.com>
In-Reply-To: <20060627220139.3168.69409.sendpatchset@tomahawk.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akpm@osdl.org, alan@lxorguk.ukuu.org.uk, arjan@infradead.org, hawkes@sgi.com, jdaiker@osdl.org, jes@sgi.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, tony.luck@gmail.com, tony.luck@intel.com

> Fixing param.h to have #define HZ sysconf(_SC_CLK_TCK) sounds
> like a plausible solution, many incorrect uses will be fixed
> automagically by the next rebuild.  But some more obscure usages
> of HZ may not compile (which is good, then they can be fixed
> properly) or worse may compile, but not do the right thing.

This makes compiles fail on one of the non-glibc libraries,
either uClibc or dietlibc, which does not provide sysconf.

The order in which procps tries things is:

1. walk off the end of environ to get the ELF notes
2. /proc/uptime to /proc/stat ratio
3. HZ
4. lame guess based on endianness and word size

I do not want sysconf. It is is an unreliable piece of shit
that gives me poor guesses instead of returning appropriate
error codes. It does this swell job while being damn slow.
I can do no worse with my own random guess.

(on my TODO list: count CPUs myself, because glibc often
thinks there are zero -- and this is not an error code)

> The ultimate safe solution might be:
>
> #define HZ Fix your program to use sysconf(_SC_CLK_TCK)! \
>       (and BTW, you should not include kernel headers)
>
> Which is highly likely to cause a compile failure (but should
> at least provide a clue to the user on what they should do).

This breaks perfectly fine code, except that it will be yet one more
thing for people to patch out when making headers for userspace.
