From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 06 May 2005 12:08:37 +0000
Subject: MINSTATE_START_SAVE_MIN_PHYS looking very confused
Message-Id: <17019.24133.738017.806202@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

While working on the libunwind-enabled Linux kernel, I noticed that
MINSTATE_START_SAVE_MIN_PHYS is loking rather confused.  Part of the
problem seems to have been introduced by rja's patch from last
December (it cause "r1" to be setup incorrectly when already in kerenl
mode).  However, the bigger issue to me is: given that we have a
separate INIT stack, why bother distinguishing between an INIT that
hits user-level vs. one that hits the kernel.  It's not possible to
handle nested INITs anyhow, so why not just simplify that code to
always switch to the INIT stack?

	--david
