From: Ingo Molnar <mingo@elte.hu>
Date: Wed, 10 Jul 2002 19:30:37 +0000
Subject: [Linux-ia64] Re: O(1) scheduler "complex" macros
Message-Id: <marc-linux-ia64-105590701905748@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905752@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905752@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

the best solution might be to just lock the 'next' task - this needs a new
per-task irq-safe spinlock, to avoid deadlocks. This way whenever a task
is in the middle of a context-switch it cannot be scheduled on another
CPU.

in fact this solution simplifies things - only two per-arch macros are
needed. I've done this in my current 2.5.25 tree:

	http://redhat.com/~mingo/O(1)-scheduler/sched-2.5.25-A4

check out the sparc64 changes for the 'complex' locking scenario - it's
untested, please give it a go on ia64, does that solve your problems? x86
is tested and works just fine.

	Ingo


