From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 13 Apr 2002 02:53:33 +0000
Subject: [Linux-ia64] preemption support
Message-Id: <marc-linux-ia64-105590701905451@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Is anyone interested in working on adding pre-emption support to the
ia64 linux kernel?  I think it would be nice to have that option.  The
mechanics of making the kernel pre-emption safe are fairly
straight-forward (see preempt* macros in 2.5).  The hard part is of
course finding all the places that need to be protected.

Don, perhaps this should be added to the todo list?

	--david

