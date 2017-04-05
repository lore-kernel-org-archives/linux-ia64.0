From: Al Viro <viro@ZenIV.linux.org.uk>
Date: Wed, 05 Apr 2017 05:05:08 +0000
Subject: ia64 exceptions (Re: [RFC][CFT][PATCHSET v1] uaccess unification)
Message-Id: <20170405050507.GQ29622@ZenIV.linux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170329055706.GH29622@ZenIV.linux.org.uk>
In-Reply-To: <20170329055706.GH29622@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org
Cc: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>

On Wed, Mar 29, 2017 at 06:57:06AM +0100, Al Viro wrote:

> And again, metag and ia64 parts are simply not there - both architectures
> zero-pad in __copy_from_user_inatomic() and that really needs fixing.
> In case of metag there's __copy_to_user() breakage as well, AFAICS, and
> I've been unable to find any documentation describing the architecture
> wrt exceptions, and that part is apparently fairly weird.  In case of
> ia64...  I can test mckinley side of things, but not the generic __copy_user()
> and ia64 is about as weird as it gets.  With no reliable emulator, at that...
> So these two are up to respective maintainers.

Speaking of ia64: copy_user.S contains the following oddity:
2:
        EX(.failure_in3,(p16) ld8 val1[0]=[src1],16)
(p16)   ld8 val2[0]=[src2],16

src1 is 16-byte aligned, src2 is src1 + 8.

What guarantees that we can't race with e.g. TLB shootdown from a thread on
another CPU, ending up with the second insn taking a fault and oopsing?

AFAICS, other places where we have such pairs of loads or stores (e.g.
EX(.ex_handler, (p16)   ld8     r34=[src0],16)
EK(.ex_handler, (p16)   ld8     r38=[src1],16)
in the memcpy_mck.S counterpart of that code) both have exception table
entries associated with them.

Is that one intentional and correct for some subtle reason, or is it a very
narrow race on the hardware nobody gives a damn anymore?  It is pre-mckinley
stuff, after all...
