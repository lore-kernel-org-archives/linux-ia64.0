From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Mon, 24 Jan 2005 19:32:27 +0000
Subject: RE: [patch] ia64: fix potential NaT bit error for sys_pipe().
Message-Id: <200501241932.j0OJWRg06230@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16878.2168.388519.26567@napali.hpl.hp.com>
In-Reply-To: <16878.2168.388519.26567@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 20 Jan 2005 19:32:48 -0800, Chen, Kenneth W
  Ken> We would rather not to change THREAD_FLAGS_TO_CLEAR definition.
  Ken> mfh bit in child pt_regs is cleared right above where the
  Ken> comment is.  I think it is better as is so that child thread
  Ken> fph partition stays invalidated.

David Mosberger Monday, January 24, 2005 11:18 AM
> Sorry, I was a bit in a rush when I typed that mail and made some
> errors as a result.  I think what you propose is reasonable, since
> just clearing PSR.MFH will take care of avoiding needless
> context-switching of f32-f127.  However, I think it'd still be
> worthwhile to update the comment in copy_thread() to reflect this
> thinking (basically, the paragraph starting with "XXX" would have to
> be updated).

Absolutely agreeing with updating the comments.  Also in a way, what
you said earlier also make sense.  Since clearing psr.mfh is only half
of the optimization.  That would only optimize away the storing part
of context switch.  However, if later we take a dfh fault, if thread fph
valid bit is on, we end up loading from memory instead of a simple zeroing.
So I better do both, clearing psr.mfh and fph valid bit in thread.flags.

- Ken


