From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 27 Nov 2001 05:19:26 +0000
Subject: [Linux-ia64] Re: kernel/sched.c -1ULL vs. (cycles_t) -1
Message-Id: <marc-linux-ia64-105590698805547@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 22 Nov 2001 11:29:05 +0100, Erich Focht <efocht@ess.nec.de> said:

  Erich> David, in your ia64 patches you have a small cosmetic change
  Erich> which is (sort of) making kernel/sched.c platform dependent:

  Erich> Would you mind taking this out or trying to get it into the
  Erich> base-line kernel?

Yes, on both accounts: now that 2.5 exists, I moved the patch to the
2.5 tree, i.e., it will be gone from 2.4 (along with a couple of other
minor patches).

	--david

