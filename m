From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 10 Sep 2001 23:40:34 +0000
Subject: [Linux-ia64] Re: [PATCH] to remove unused hcl_spinlock
Message-Id: <marc-linux-ia64-105590698805165@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 07 Sep 2001 15:01:40 -0700, "David C. Hansen" <haveblue@us.ibm.com> said:

  David.Hansen> I was looking at spinlocks in the kernel and came
  David.Hansen> across hcl_spinlock.  If you look at this paper:
  David.Hansen> http://lse.sourceforge.net/lockhier/global-spin-lock ,
  David.Hansen> you can see a part on hcl_spinlock.  It is
  David.Hansen> initialized. but never used.  Was this lock meant to
  David.Hansen> guard something?  Is that thing still in the code?  If
  David.Hansen> it isn't, here is a patch to remove hcl_spinlock.

Just FYI: stuff in the sn/ subdirectories is SGI specific.  Since I
can't test that, I try to avoid touching it and it would be up to SGI
to incorporate your patch (I suspect they have fixed that already: the
SN code hasn't been synced in a while).

	--david

