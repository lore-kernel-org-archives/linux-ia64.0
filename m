From: Ingo Molnar <mingo@elte.hu>
Date: Wed, 10 Jul 2002 18:31:03 +0000
Subject: [Linux-ia64] Re: O(1) scheduler "complex" macros
Message-Id: <marc-linux-ia64-105590701905747@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905752@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905752@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 9 Jul 2002, Erich Focht wrote:

> Suppose we have 
>   cpu1: idle1
>   cpu2: prev2 -> next2  (in the switch)
> 
> I don't understand how task_lock(prev2) done on cpu2 can prevent cpu1 to
> schedule prev2, which it stole after the RQ#2 lock release. It will just
> try to task_lock(idle1), which will be successfull.

you are right - the 'complex' macros also need to lock the 'next' task,
not only the 'previous' task - but to do that deadlock-free, they need to
drop the runqueue lock ...

	Ingo


