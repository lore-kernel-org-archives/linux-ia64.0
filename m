From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 27 Aug 2002 18:15:54 +0000
Subject: [Linux-ia64] heads up: 2.4.18 bug causing bad value in siginfo.si_fd
Message-Id: <marc-linux-ia64-105590701905986@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

It has been brought to my attention that there is a bug in the ia64
version of 2.4.18 which causes a bad value to be returned in the si_fd
member of the siginfo structure.  This bug occurs at least for siginfo
values returned by sigtimedwait(), but I suspect the root cause is in
the siginfo-copying routines so normal signal deliver probably also
results in a bad si_fd value.

The bug is not present in 2.4.19 and 2.5.31.

	--david

