From: Al Viro <viro@ZenIV.linux.org.uk>
Date: Wed, 05 Apr 2017 08:08:57 +0000
Subject: Re: ia64 exceptions (Re: [RFC][CFT][PATCHSET v1] uaccess unification)
Message-Id: <20170405080857.GR29622@ZenIV.linux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170329055706.GH29622@ZenIV.linux.org.uk>
 <20170405050507.GQ29622@ZenIV.linux.org.uk>
In-Reply-To: <20170405050507.GQ29622@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org
Cc: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>

On Wed, Apr 05, 2017 at 06:05:08AM +0100, Al Viro wrote:

> Speaking of ia64: copy_user.S contains the following oddity:
> 2:
>         EX(.failure_in3,(p16) ld8 val1[0]=[src1],16)
> (p16)   ld8 val2[0]=[src2],16
> 
> src1 is 16-byte aligned, src2 is src1 + 8.
> 
> What guarantees that we can't race with e.g. TLB shootdown from a thread on
> another CPU, ending up with the second insn taking a fault and oopsing?
> 
> AFAICS, other places where we have such pairs of loads or stores (e.g.
> EX(.ex_handler, (p16)   ld8     r34=[src0],16)
> EK(.ex_handler, (p16)   ld8     r38=[src1],16)
> in the memcpy_mck.S counterpart of that code) both have exception table
> entries associated with them.
> 
> Is that one intentional and correct for some subtle reason, or is it a very
> narrow race on the hardware nobody gives a damn anymore?  It is pre-mckinley
> stuff, after all...

Actually, the piece immediately after that one is worse.  By that point,
we have
	* checked that len is large enough to be worth bothering with word
copies.  Fine.
	* checked that src and dst have the same remainder modulo 8.
	* copied until src is a multiple of 16, incrementing src and dst
by the same amount.
	* prepared for copying in multiples of 16 bytes
	* set src2 and dst2 8 bytes past src1 and dst1 resp.
and now we have a pipelined loop with
        EX(.failure_in3,(p16) ld8 val1[0]=[src1],16)
(p16)   ld8 val2[0]=[src2],16

        EX(.failure_out, (EPI)  st8 [dst1]=val1[PIPE_DEPTH-1],16)
(EPI)   st8 [dst2]=val2[PIPE_DEPTH-1],16
for body.  Now, consider the following case:

	* to is 8 bytes before the end of user page, next page is unmapped
	* from is at the beginning of kernel page
	* len is simply PAGE_SIZE

and we call copy_to_user().  All the preparation work won't read or write
anything - all alignments are fine.  src1 and src2 are kernel page and
kernel page + 8 resp.; dst1 is 8 bytes before the end of user page, dst2
is at the beginning of unmapped user page.  No loads are going to fail;
the first store into dst1 won't fail either.  The *second* store - one to
dst2 will not just fail, it'll oops.

<goes to test>

... and sure enough, on generic kernel (CONFIG_ITANIUM) that yields a nice
shiny oops at precisely that insn.

We really need tests for uaccess primitives.  That's not a recent regression,
BTW - it had been that way since 2.3.48-pre2, as far as I can see.
