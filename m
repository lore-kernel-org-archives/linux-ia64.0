From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 11 Dec 2003 20:28:14 +0000
Subject: Re: ia64 atomic_dec_and_lock() patch
Message-Id: <marc-linux-ia64-107117481027731@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107107082810707@msgid-missing>
In-Reply-To: <marc-linux-ia64-107107082810707@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jerome,

>>>>> On Thu, 11 Dec 2003 10:58:22 +0100 (NFT), jerome.marchand@ext.bull.net said:

  Jerome> On Wed, 10 Dec 2003, David Mosberger wrote:

  >> Could you try replacing the inline-asm with cmpxchg() function?
  >> That way, you won't break compilation with Intel's compiler.

  Jerome> OK, here's the new patch.

Thanks for switching to cmpxchg.

  Jerome> I also join the right patch for lockmeter.

You lost me here.  The patch seems all messed up to me, because the
standard kernel doesn't include lockmeter and I really don't want any
lockmeter-specific code in the normal kernel.

Secondly, I really dislike using goto's to teach the compiler about
branch-probabilities.  The likely()/unlikely() macros lead to much
more readable code (yes, I know that you simply mirrored the i386...).

Third, I think the EXPORT_SYMBOL() was missing for atomic_dec_and_lock().

Anyhow, rather than going through another iteration, I just fixed up
the code myself.  See:

  http://lia64.bkbits.net:8080/to-linus-2.5/cset@1.1503

With this code, GCC pre3.4 emits this for the fast path:


      alloc r2=ar.pfs,2,2,0
1:    ld4.acq r15=[r32];;
      cmp4.eq p9,p8=1,r15
      adds r16=-1,r15
      zxt4 r14=r15
(p09) br.cond.dpnt.few slow_path
      mov.m ar.ccv=r14;;
      cmpxchg4.acq r8=[r32],r16,ar.ccv;;
      cmp4.eq p10,p11=r8,r15
(p11) br.cond.dptk.few 1b
      mov r8=r0
      mov.i ar.pfs=r2
      br.ret.sptk.many b0

I think that's about as good as it gets, apart from not being able to
schedule around latencies.  If you want to play with this some more,
it might be worthwhile to inline the fast path by moving it into
spinlock.h.  But that would only make sense if the
(performance-critical) users of atomic_dec_and_lock are not leaf
functions.

Thanks,

	--david
