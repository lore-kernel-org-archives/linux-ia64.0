From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 28 Feb 2004 06:52:46 +0000
Subject: Re: Oops in pdflush
Message-Id: <16448.15038.132551.960807@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <je4qtl7u44.fsf@sykes.suse.de>
In-Reply-To: <je4qtl7u44.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sat, 28 Feb 2004 00:58:20 +1100, Keith Owens <kaos@sgi.com> said:

  Keith> On Fri, 27 Feb 2004 11:16:03 +0100,
  Keith> Andreas Schwab <schwab@suse.de> wrote:
  >> pdflush[18140]: Oops 11012296146944 [1]

  >> Pid: 18140, CPU 1, comm:              pdflush
  >> psr : 0000121008026018 ifs : 8000000000000590 ip  : [<a00000010046e0d1>]    Not tainted
  >> ip is at nf_iterate+0x111/0x240
  >> unwind.init_frame_info:
  >> task   0xe0000000110e0000
  >> rbs = [0xe0000000110e0ef0-0xe0000000110e6ac8)
  >> stk = [0xe0000000110e6ac8-0xe0000000110e8000)
  >> pr     0x82aa6aa6a55596a7
  >> sw     0xe0000000110e6160
  >> sp     0xe0000000110e6ac8

  Keith> Ouch.  rbs and stack have collided, kernel stack overflow.  rbs shows
  Keith> a normal start, then it loops with the same data over and over again

So if I'm reading this right, we get a case that looks like unbounded
recursion:

	pdflush -> start_one_pdflush_thread -> kernel_thread -> pdflush ...

Except, I don't think this is real recursion.  Instead, we effectively
get a (potentially unbounded) sequence of one kernel thread creating
another thread.  Each new kernel thread gets nested one deeper,
eventually leading to a stack overflow...

Argh, this wasn't supposed to happen!  It's not entirely trivial to
fix.  Obviously we could try to modify copy_thread() so it resets the
stack to the top, but in doing so, we still must preserve the stack
frame of kernel_thread().  That wouldn't be a problem---if only we
knew how big that frame was!  (Well, OK, then there would also be RNaT
slots to worry about, but that could be handled by ensuring that the
new and old stacks are congruent in that regard).

Hmmh, I think perhaps the right way to fix this is to use a separate
continuation function, which will then take care of doing the
child-specific actions.  Let me see if I can come up with something.

Oh, well, now I'm finding that this is of course exactly how Linus
changed the x86 code some 19 months ago (for other reasons though, it
seems):

  http://linux.bkbits.net:8080/linux-2.5/diffs/arch/i386/kernel/process.c@1.19.1.11

Say, Andreas, did you by chance have 3 disk drives in your Tiger?
Does it boot fine if you remove one or two of the disks?

	--david
