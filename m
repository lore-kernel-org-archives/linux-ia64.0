From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 18 Mar 2003 23:12:22 +0000
Subject: [Linux-ia64] Re: [PATCH] remove stale mmiob function
Message-Id: <marc-linux-ia64-105590723705265@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 18 Mar 2003 10:15:27 -0800, Jesse Barnes <jbarnes@sgi.com> said:

  Jesse> The consensus on lkml was that devices should do reads from
  Jesse> safe registers to ensure PIO write ordering, which means we
  Jesse> no longer need mmiob.  This patch removes the mmiob entries
  Jesse> from the machine vector headers and io.h and updates the
  Jesse> documentation about PIO ordering.

Applied, thanks.

	--david

