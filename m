From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 20 Jan 2005 23:51:22 +0000
Subject: RE: [patch] ia64: fix potential NaT bit error for sys_pipe().
Message-Id: <16880.17402.208039.592157@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16878.2168.388519.26567@napali.hpl.hp.com>
In-Reply-To: <16878.2168.388519.26567@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 20 Jan 2005 15:22:59 -0800, "Seth, Rohit" <rohit.seth@intel.com> said:

  Rohit> We are also thinking of reseting the mfh bit on every syscall
  Rohit> entry as an optimization.

  Rohit> Comments?

Sounds OK with me.  We should delete this comment from process.c then,
too:

        /*
         * NOTE: The calling convention considers all floating point
         * registers in the high partition (fph) to be scratch.  Since
         * the only way to get to this point is through a system call,
         * we know that the values in fph are all dead.  Hence, there
         * is no need to inherit the fph state from the parent to the
         * child and all we have to do is to make sure that
         * IA64_THREAD_FPH_VALID is cleared in the child.
         *
         * XXX We could push this optimization a bit further by
         * clearing IA64_THREAD_FPH_VALID on ANY system call.
         * However, it's not clear this is worth doing.  Also, it
         * would be a slight deviation from the normal Linux system
         * call behavior where scratch registers are preserved across
         * system calls (unless used by the system call itself).
         */

and change:

#define THREAD_FLAGS_TO_CLEAR (IA64_THREAD_FPH_VALID | IA64_THREAD_DBG_VALID \
                               | IA64_THREAD_PM_VALID)

to:

#define THREAD_FLAGS_TO_CLEAR (IA64_THREAD_DBG_VALID | IA64_THREAD_PM_VALID)

	--david
