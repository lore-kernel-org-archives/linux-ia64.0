From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 26 Nov 2001 23:12:57 +0000
Subject: Re: [Linux-ia64] 2.4.14 Missing asm clobbers
Message-Id: <marc-linux-ia64-105590698805544@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805537@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805537@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 21 Nov 2001 11:40:56 +1100, Keith Owens <kaos@ocs.com.au> said:

  Keith> include/asm-ia64/spinlock.h.

  Keith>   spin_lock() changes ar.ccv, p7 without a clobber (!NEW_LOCK
  Keith> version).  read_lock() changes p6 without a clobber.
  Keith> write_lock() changes ar.ccv, p7 without a clobber.

Ok, those should be fixed now.  They clearly are needed, though I
don't think the missing ar.ccv really had any effect because gcc uses
that register only for the builtin synchronization ops use them (which
we don't use in the kernel).

  Keith> arch/ia64/kernel/traps.c

  Keith>   fp_emulate() does ldf f10, f11 without a clobber.

That's fine because f10 and f11 are marked "fixed" on the command
line.

  Keith> arch/ia64/kernel/unaligned.c

  Keith>   invala_gr() and invala_fr() do invala without a "memory"
  Keith> clobber.  Not sure if it is necessary or not.

This is fine because the instructions affect the code that caused the
unaliged access, not the unaligned handler itself.  However, we
shouldn't need that code anymore because we now do an "invala" on
entry to the kernel.  I'll remove it in 2.5.xx.

Thanks,

	--david

