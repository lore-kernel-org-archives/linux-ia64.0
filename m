From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 25 Mar 2004 19:41:53 +0000
Subject: should ia64_spinlock_contention do backoff?
Message-Id: <200403251941.i2PJfrTH026392@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Has anyone studied the impact of doing exponential backoff in
ia64_spinlock_contention.  My theory is that it wouldn't buy much _if_
spinlocks always were in their own cachelines, but since they're not,
not using backoff could cause extra cache-line bouncing.  To be
honest, I'd rather not spend time on this myself, since I don't have
convenient access to large machines, but me thinks this is a question
that's long overdue to have a proper answer.

	--david
