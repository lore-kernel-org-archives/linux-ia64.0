From: Ingo Molnar <mingo@elte.hu>
Date: Thu, 11 Jul 2002 09:39:39 +0000
Subject: [Linux-ia64] Re: O(1) scheduler "complex" macros
Message-Id: <marc-linux-ia64-105590701905754@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905752@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905752@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>  #define task_running(rq, p) \
> 	((rq)->curr = (p)) && !spin_is_locked(&(p)->switch_lock)

one more implementational note: the above test is not 'sharp' in the sense
that on SMP it's only correct (the test has no barriers) if the runqueue
lock is held. This is true for all the critical task_running() uses in
sched.c - and the cases that use it outside the runqueue lock are
optimizations so they dont need an exact test.

	Ingo


