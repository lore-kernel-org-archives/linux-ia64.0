From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 21 May 2003 17:56:19 +0000
Subject: [Linux-ia64] Re: web page on O(1) scheduler
Message-Id: <marc-linux-ia64-105590723705972@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705966@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705966@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 21 May 2003 11:26:31 +0200, Mike Galbraith <efault@gmx.de> said:

  Mike> The page mentions persistent starvation.  My own explorations
  Mike> of this issue indicate that the primary source is always
  Mike> selecting the highest priority queue.

My working assumption is that the problem is a bug with the dynamic
prioritization.  The task receiving the signals calls sleep() after
handling a signal and hence it's dynamic priority should end up higher
than the priority of the task sending signals (since the sender never
relinquishes the CPU voluntarily).

However, I haven't actually had time to look at the relevant code, so
I may be missing something.  If you understand the issue better,
please explain to me why this isn't a dynamic priority issue.

	--david

