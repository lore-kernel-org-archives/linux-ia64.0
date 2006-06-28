From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 28 Jun 2006 17:36:35 +0000
Subject: RE: [PATCH] ia64: change usermode HZ to 250
Message-Id: <617E1C2C70743745A92448908E030B2A27FC5F@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060627220139.3168.69409.sendpatchset@tomahawk.engr.sgi.com>
In-Reply-To: <20060627220139.3168.69409.sendpatchset@tomahawk.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alan Cox <alan@lxorguk.ukuu.org.uk>, John Daiker <jdaiker@osdl.org>
Cc: John Hawkes <hawkes@sgi.com>, Arjan van de Ven <arjan@infradead.org>, Tony Luck <tony.luck@gmail.com>, Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Jack Steiner <steiner@sgi.com>, Dan Higgins <djh@sgi.com>, Jeremy Higdon <jeremy@sgi.com>

> In the cached HZ case there will be no performance hit of measure
> anyway. The bigger problem is existing user space. That is why we've
> always kept the user visible HZ based values the same when changing the
> kernel HZ. You can't automatically regenerate all the old binaries you
> might otherwise break.

No we haven't kept user visible HZ the same ... look at times(2)
it reports in "clock ticks", and has a note on the manual page
that you must use sysconf(_SC_CLK_TCK) to find out how many ticks
are in a second.  So dusty deck binaries with hard-coded 100 (or
even older ones with 60 or 50) have been broken for a while now.

Also note that the sysconf(_SC_CLK_TCK) call doesn't take a
system call, the kernel passes CLOCKS_PER_SEC in the AT_CLKTCK
auxilliary vector during fs/binfmt_elf.c:create_elf_tables(),
so glibc can complete this call with a simple table lookup in
userspace.

Fixing param.h to have #define HZ sysconf(_SC_CLK_TCK) sounds
like a plausible solution, many incorrect uses will be fixed
automagically by the next rebuild.  But some more obscure usages
of HZ may not compile (which is good, then they can be fixed
properly) or worse may compile, but not do the right thing.

Removing it completely might be better, it may force people to
look at how they are using HZ.  But there are probably many old
programs that have:

#ifndef HZ
#define HZ 60
#endif

So this won't catch them.

The ultimate safe solution might be:

#define HZ Fix your program to use sysconf(_SC_CLK_TCK)! \
	(and BTW, you should not include kernel headers)

Which is highly likely to cause a compile failure (but should
at least provide a clue to the user on what they should do).

-Tony
