From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 13 Apr 2004 16:25:41 +0000
Subject: RE: Questions on the stack for IA64
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F010E2018@scsmsx401.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040413051722.84368.qmail@web61202.mail.yahoo.com>
In-Reply-To: <20040413051722.84368.qmail@web61202.mail.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

 

>-----Original Message-----
>From: linux-ia64-owner@vger.kernel.org 
>[mailto:linux-ia64-owner@vger.kernel.org] On Behalf Of Rahul Chaturvedi
>Sent: Monday, April 12, 2004 10:17 PM
>a.) The stack pointer seems to be r12, which is
>pointing to a location along the lines of,
>
>0x60000fffffffxxxx
>
>Shouldn't this address be in the 0x8xxxxxxxxxxxxxxx
>range? Isn't the 0x6xxxxxxxxxxxxxxx range reserved for
>the data segment?

The user stack was moved from region 4 (0x8....) to
region 3 (0x6....) to free up region 4 for use by the
hugetlbfs code (using large page size like 256M for
very large objects to reduce TLB overhead).

>I also checked the address of a global variable, and
>it was stored at in the 0x6xxxxxxxxxxxxxxx range.
>Wouldn't the stack and the data segment conflict?

64-bit address space is very large ... so the data and
stack are still very far apart, even though they have
addresses in region 3.

>b.) There is something called $GP and $TP that the
>compiler defines as r1 and r13 respectively. Anyone
>got any idea what they are?

r1 is used for simple access to some of the data, without
it you would need to use "movl reg=<64-bit value>" to get
the address of a global.  Using it, many data objects can
be accessed using relative addressing from the $GP, a.k.a.
__gp address.  $TP is used in the same way for thread local
storage.

>c.) How exactly is the data stored in the bspstore
>locations?

The processor writes out stacked registers to the bspstore
area "in the background" while other execution is happening.

>d.) The pfs register seems to point to a location in
>0xcxxxxxxxxxxxxxxx. Shouldn't this point to some
>accessible memory location (from usermode)?

someone else can take this one?

>e.) For some reason, compiled code, even with full
>optimizations seems to do a "st8" on any value I put
>in a local variable. For example, I have a function
>with about 40 variables, the intel compiler that I am
>using does something like,
>
>mov r47, value
>st8 [r48], r47
>
>GCC also does something similar.
>
>Shouldn't the compiler simply store the value in r47
>instead of st8'ing it to memory when using full
>optimizations (-O2)?

Can you provide a sample of C-code that results in this
excessive storing to memory?

-Tony
