From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 21 Oct 2004 14:30:55 +0000
Subject: Re: [patch 2.6.9] Avoid a rare deadlock during unwind
Message-Id: <16759.51231.826151.918195@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <9718.1098174005@kao2.melbourne.sgi.com>
In-Reply-To: <9718.1098174005@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 19 Oct 2004 18:20:05 +1000, Keith Owens <kaos@sgi.com> said:

  Keith> There is a rare deadlock condition during unwind script
  Keith> creation.  If build_script() is interrupted in the middle of
  Keith> creating the script, it holds the script write lock.  If the
  Keith> interrupt handler needs to call unwind for some failure
  Keith> condition, unwind will try to read the incomplete script and
  Keith> will deadlock on the script lock.

  Keith> The fix is to disable interrupts while building the script,
  Keith> so interrupt handlers never see partial scripts.

  Keith> Promoting spin_lock_irqsave() from script_new() to
  Keith> find_save_locs() changes the indentation, so the patch looks
  Keith> bigger than it really is.

I'm not sure this is safe.  You're now acquiring the read/write-lock
after the spinlock and according to the SMP conventions mentionted at
the beginning of the file, this isn't safe:

 *      o if both the unw.lock spinlock and a script's read-write lock must be
 *        acquired, then the read-write lock must be acquired first.

Did you check that this isn't a problem?  If so, it would at least be
necessary to update the comment.

	--david
