From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 13 Mar 2003 19:16:26 +0000
Subject: [Linux-ia64] Re: ia64_spinlock_contention and NEW_LOCK
Message-Id: <marc-linux-ia64-105590709806081@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806055@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806055@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 13 Mar 2003 08:18:49 +1100, Keith Owens <kaos@sgi.com> said:

  Keith> On Wed, 12 Mar 2003 09:27:14 -0800, 
  Keith> David Mosberger <davidm@napali.hpl.hp.com> wrote:
  >> This is wrong:

  >> +	.prologue
  >> +	.altrp b7
  >> +	.save ar.pfs, r29
  >> +	mov b7=r28		// my "return" address
  >> +	mov r29=0		// dummy ar.pfs, pretend zero frame size

  >> You have a 1-instruction window where the unwind info is wrong.
  >> Single-stepping with the latest Ski beta and using the "cstack"
  >> command, you should be able to see the problem.

  Keith> I know, but do not see any way around it.

It should be easy to fix: save ar.pfs in a scratch register, then use
br.call/brl.call to invoke the ia64_spinlock_contention.  Then
everything will work out properly.

  >> In general, I'm quite nervous about doing such trickery underneath the
  >> compiler.  Would you be interested in trying out the alternative of
  >> simply using __sync_val_compare_and_swap(), likely()/unlikely() and
  >> making ia64_spinlock_contention() a normal procedure?  I'd rather
  >> pester the compiler folks than live with code that's bound to bite us
  >> in the future. ;-)

  Keith> My biggest concern with calling any C code from spinlock contention is
  Keith> the potential for unbounded recursion.  If the C code does anything
  Keith> that uses a spinlock (including printk) then we could end up back in
  Keith> the contention code and blow the stack.  The asm code is tricky but
  Keith> safe.

I see your point, but I don't think it's a very strong argument.  In
any case, as long as GCC doesn't do shrink-wrapping, a pure C solution
may not be practical anyhow.

	--david

