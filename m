From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 15 Mar 2003 01:30:01 +0000
Subject: Re: [Linux-ia64] [patch] 2.4.20-ia64-021210 new spinlock code
Message-Id: <marc-linux-ia64-105590709806127@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805543@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805543@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sat, 15 Mar 2003 12:10:38 +1100, Keith Owens <kaos@sgi.com> said:

  Keith> Patch is against 2.4.20-ia64-021210.  Reduce the uncontended
  Keith> spinlock path from 5 bundles to 3 (McKinley) or 4 (Itanium),
  Keith> both have one less memory access on the uncontended path.
  Keith> Move the contended path out of line so we can do exponential
  Keith> backoff, kdb, lock metering etc. in one place.

  Keith> David, closing the 1 bundle unwind window was a bit harder
  Keith> than I expected, it turns out that altrp does not specify
  Keith> where it applies, it is prologue global.  To get altrp to
  Keith> apply after mov b7=r28, I needed multiple prologues and
  Keith> bodies.  AFAICT this will unwind correctly on any instruction
  Keith> within ia64_spinlock_contention.  Could you verify that on
  Keith> your simulator (assuming it supports .save ar.pfs,r0)?

I think it's correct, but more complicated than it has to be: you
should be able to use the general directive ".spillreg rp, b7" instead
of ".altrp".

Another suggestion: use #ifndef CONFIG_ITANIUM instead of #ifdef
CONFIG_MCKINLEY.  This ensures that brl will be used on future CPUs as
well (as it should be).

	--david

