From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 12 Mar 2003 01:59:56 +0000
Subject: Re: [Linux-ia64] ia64_spinlock_contention and NEW_LOCK
Message-Id: <marc-linux-ia64-105590709806046@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806001@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806001@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 12 Mar 2003 12:38:32 +1100, Keith Owens <kaos@sgi.com> said:

  Keith> Can you remember what was wrong with the out of line
  Keith> contention code?  The obvious problems are the lack of unwind
  Keith> data, it will not work for spin locks in modules (PCREL21B
  Keith> will not reach from region 5 to region 7) and the fact that
  Keith> ar.pfs gets corrupted (gcc 2.96 does not recognise that
  Keith> ar.pfs in the clobber list means leaf functions must now save
  Keith> ar.pfs).  Were there any other problems?

You mean: apart from being completely broken, it looks great? ;-)

Seriously though: I think the main problem is trying to do branch to
out-of-line code without the compiler knowing about it.  The main
reason I wanted to do that is to avoid turning leaf routines into
interior routines just because of a spinlock acquisition.

I'd actually much prefer to _reduce_ the amount of assembly code in
spinlock.h and to use the ia64intrin.h builtins instead.  If we tag
the critical expressions with __builtin_expect(), the compiler would
have enough information to do the Right Thing.  In fact, if the
compiler were able to do "shrink-wrapping", it could even avoid
turning leafs into non-leafs (for the uncontended case).  That way,
the back-off algorithm could be implemented as a normal C routine,
which would make everything much nicer.  (Last time I checked, there
were no plans to support shrink-wrapping in GCC, but that may have
changed.  The Intel compiler probably does support it though, but I
don't know whether it honors __builtin_expect()).

	--david

