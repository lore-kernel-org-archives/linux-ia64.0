From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 24 Jan 2005 19:43:14 +0000
Subject: RE: [patch] ia64: fix potential NaT bit error for sys_pipe().
Message-Id: <16885.20434.940501.628304@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16878.2168.388519.26567@napali.hpl.hp.com>
In-Reply-To: <16878.2168.388519.26567@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 24 Jan 2005 11:32:27 -0800, "Chen, Kenneth W" <kenneth.w.chen@intel.com> said:

  Ken> Absolutely agreeing with updating the comments.  Also in a way,
  Ken> what you said earlier also make sense.  Since clearing psr.mfh
  Ken> is only half of the optimization.  That would only optimize
  Ken> away the storing part of context switch.  However, if later we
  Ken> take a dfh fault, if thread fph valid bit is on, we end up
  Ken> loading from memory instead of a simple zeroing.  So I better
  Ken> do both, clearing psr.mfh and fph valid bit in thread.flags.

OK, I had assumed that you had tested this already.  Clearing the
FPH_VALID bit in the syscall path does potentially increase the
syscall overhead as it requires a read-modify-write.  Cache-wise we
should be OK, since the neighboring "on_ustack" byte is being touched
anyhow.  If the code turns out to be difficult to schedule in the
syscall path, an alternate option would be to make FPH_VALID a
separate byte member, right next to on_ustack, so it can be cleared
with "st1 [rXX]=r0".

	--david

