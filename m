From: Keith Owens <kaos@sgi.com>
Date: Wed, 12 Mar 2003 21:18:49 +0000
Subject: [Linux-ia64] Re: ia64_spinlock_contention and NEW_LOCK
Message-Id: <marc-linux-ia64-105590709806072@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806055@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806055@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 12 Mar 2003 09:27:14 -0800, 
David Mosberger <davidm@napali.hpl.hp.com> wrote:
>This is wrong:
>
>+	.prologue
>+	.altrp b7
>+	.save ar.pfs, r29
>+	mov b7=r28		// my "return" address
>+	mov r29=0		// dummy ar.pfs, pretend zero frame size
>
>You have a 1-instruction window where the unwind info is wrong.
>Single-stepping with the latest Ski beta and using the "cstack"
>command, you should be able to see the problem.

I know, but do not see any way around it.  I do not really care about
single stepping through that 1 instruction window, my primary concern
is getting a decent backtrace when you interrupt a cpu that is spinning
in the body of ia64_spinlock_contention.

>Also, it is wrong to pretend to have a zero ar.pfs, since in general
>that won't match with the caller's register frame (and the .save
>directive would have to go in front of the "mov r29=0" instruction, if
>anything).  Makes you wish we had a ".alias" unwind directive, which
>would specify a register that points to the code with the real unwind
>info.

ia64_spinlock_contention effectively has a zero frame size, it cannot
use any stack registers.  Unwind via b7 and you see the caller's frame
size, and the rest of the unwind works from there, as demonstrated by
the kdb backtrace working fine.

>In general, I'm quite nervous about doing such trickery underneath the
>compiler.  Would you be interested in trying out the alternative of
>simply using __sync_val_compare_and_swap(), likely()/unlikely() and
>making ia64_spinlock_contention() a normal procedure?  I'd rather
>pester the compiler folks than live with code that's bound to bite us
>in the future. ;-)

My biggest concern with calling any C code from spinlock contention is
the potential for unbounded recursion.  If the C code does anything
that uses a spinlock (including printk) then we could end up back in
the contention code and blow the stack.  The asm code is tricky but
safe.


