From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 08 Mar 2002 06:38:20 +0000
Subject: [Linux-ia64] kernel update (relative to 2.5.5)
Message-Id: <marc-linux-ia64-105590701905237@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

OK, I finally got around to take another stab at 2.5.5.  The result
can be found at ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.5/
in file:

	linux-2.5.5-ia64-020307.diff.gz

This is mostly a sync up with 2.5.5, though all the changes that made
it into 2.4.18 should be there as well.  With this patch, the task
memory has the following layout:

	- "current" points to "struct task_struct"
	- "struct thread_info" follows directly above "struct task_struct"
	- rest of the memory is used for the kernel stack

I tested this on a dual Big Sur and the HP Ski simulator (SMP only).

	--david

