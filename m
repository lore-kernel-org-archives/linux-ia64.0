From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 12 Mar 2003 17:27:14 +0000
Subject: [Linux-ia64] Re: ia64_spinlock_contention and NEW_LOCK
Message-Id: <marc-linux-ia64-105590709806060@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806055@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806055@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 12 Mar 2003 21:19:37 +1100, Keith Owens <kaos@sgi.com> said:

  Keith> The inline code for an uncontended lock drops from 5 to 4
  Keith> bundles for each use of spin_lock().  The uncontended path
  Keith> has one less memory access.

Good.

For McKinley and later, you can use brl to avoid the
movl/indirect-branch combo.

  Keith> This code works for spin_lock() in built in code and for
  Keith> modules.  It does not affect the status of leaf functions, no
  Keith> change to ar.pfs or b0.

This is wrong:

+	.prologue
+	.altrp b7
+	.save ar.pfs, r29
+	mov b7=r28		// my "return" address
+	mov r29=0		// dummy ar.pfs, pretend zero frame size

You have a 1-instruction window where the unwind info is wrong.
Single-stepping with the latest Ski beta and using the "cstack"
command, you should be able to see the problem.

Also, it is wrong to pretend to have a zero ar.pfs, since in general
that won't match with the caller's register frame (and the .save
directive would have to go in front of the "mov r29=0" instruction, if
anything).  Makes you wish we had a ".alias" unwind directive, which
would specify a register that points to the code with the real unwind
info.

In general, I'm quite nervous about doing such trickery underneath the
compiler.  Would you be interested in trying out the alternative of
simply using __sync_val_compare_and_swap(), likely()/unlikely() and
making ia64_spinlock_contention() a normal procedure?  I'd rather
pester the compiler folks than live with code that's bound to bite us
in the future. ;-)

	--david

