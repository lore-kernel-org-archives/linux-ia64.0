From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 09 Apr 2004 00:07:44 +0000
Subject: Re: [patch] 2.6.5 Improve interrupt handling on contended spinlocks
Message-Id: <16501.59728.931030.482949@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4198.1081394377@kao2.melbourne.sgi.com>
In-Reply-To: <4198.1081394377@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 08 Apr 2004 13:19:37 +1000, Keith Owens <kaos@sgi.com> said:

  Keith> spin_lock_irqsave() on a contended lock leaves interrupts disabled
  Keith> while waiting for the lock.  If the interrupts were enabled before
  Keith> spin_lock_irqsave then this has the nasty side effect of preventing
  Keith> interrupt handling while waiting for the lock.  Change the contention
  Keith> path to enable interrupts if it is safe to do so, allowing the cpu to
  Keith> process interrupts while waiting for the lock.

Seems like a reasonable thing to me.  I'm fine with the ia64-specific
bits, so I guess the only question is whether the linux/spinlock.h
bits will be accepted.

	--david

