From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 09 Apr 2004 16:07:54 +0000
Subject: Re: [patch] 2.6.5 Improve interrupt handling on contended spinlocks
Message-Id: <16502.51802.317769.526887@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4198.1081394377@kao2.melbourne.sgi.com>
In-Reply-To: <4198.1081394377@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 09 Apr 2004 17:42:11 +1000, Keith Owens <kaos@sgi.com> said:

  Keith> On Thu, 8 Apr 2004 17:07:44 -0700, David Mosberger
  Keith> <davidm@napali.hpl.hp.com> wrote:
  >>>>>>> On Thu, 08 Apr 2004 13:19:37 +1000, Keith Owens
  >>>>>>> <kaos@sgi.com> said:
  >>
  Keith> spin_lock_irqsave() on a contended lock leaves interrupts
  Keith> disabled while waiting for the lock.  If the interrupts were
  Keith> enabled before spin_lock_irqsave then this has the nasty side
  Keith> effect of preventing interrupt handling while waiting for the
  Keith> lock.  Change the contention path to enable interrupts if it
  Keith> is safe to do so, allowing the cpu to process interrupts
  Keith> while waiting for the lock.
  >>  Seems like a reasonable thing to me.  I'm fine with the
  >> ia64-specific bits, so I guess the only question is whether the
  >> linux/spinlock.h bits will be accepted.

  Keith> Catch 22.  The ia64 code cannot be changed without the change
  Keith> to linux/spinlock.h, that change cannot be justified without
  Keith> at least one architecture using it.  David, could you send
  Keith> the change to Linus as an ia64 patch, other architectures can
  Keith> define _raw_spin_lock_flags if they want it.

No, it's not a catch 22.  Just send the patch upstream and tell them
the ia64-portion has my approval.  I just don't have time at the
moment to push this patch on.

	--david
