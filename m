From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 21 Nov 2001 01:37:16 +0000
Subject: Re: [Linux-ia64] 2.4.14 Missing asm clobbers
Message-Id: <marc-linux-ia64-105590698805538@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805537@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805537@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Thanks for reporting on this.  I'm certain some of asm need to be
fixed given not-so-recent compiler developments, though I'm not aware
of there being any real problems in this area at the moment.  I'll
look into it next week.

	--david

>>>>> On Wed, 21 Nov 2001 11:40:56 +1100, Keith Owens <kaos@ocs.com.au> said:

  Keith> A comment of Linus's on l-k promoted me to check ia64 inline
  Keith> asm for predicates.  I was surprised to find what look like
  Keith> missing asm clobbers.  I am not 100% sure that these are
  Keith> errors (gcc clobbers are a black art ;) so there is no patch.

  Keith> include/asm-ia64/spinlock.h.

  Keith>   spin_lock() changes ar.ccv, p7 without a clobber (!NEW_LOCK
  Keith> version).  read_lock() changes p6 without a clobber.
  Keith> write_lock() changes ar.ccv, p7 without a clobber.

  Keith> arch/ia64/kernel/traps.c

  Keith>   fp_emulate() does ldf f10, f11 without a clobber.

  Keith> arch/ia64/kernel/unaligned.c

  Keith>   invala_gr() and invala_fr() do invala without a "memory"
  Keith> clobber.  Not sure if it is necessary or not.

