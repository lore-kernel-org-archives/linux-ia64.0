From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 28 May 2003 15:53:07 +0000
Subject: [Linux-ia64] heads up: current bk tree & lightweight syscalls
Message-Id: <marc-linux-ia64-105590723706054@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The syscall optimizations temporarily broke the lightweight system
call infrastructure (because the optimized paths no longer preserve
b6 and r11).  I hope to have a fix for that today (with everything
going faster in the end...).

	--david

