From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 30 Sep 2009 01:30:02 +0000
Subject: Re: [git pull] ia64 changes
Message-Id: <alpine.LFD.2.01.0909291825350.6996@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



On Tue, 29 Sep 2009, Linus Torvalds wrote:
> 
> That may sound like ticket locks are nasty, but there are some upsides. In 
> particular, the fairness of the ticket locks means that latencies are 
> bounded. And just for that simple reason there is often much less reason 
> to worry about having to re-enable interrupts: the bounded upper case is 
> not true of traditional locks.

Just to continue on that point: with the old locks on x86, we had test 
loads that had basically 10,000:1 factors of unfairness, where one CPU 
would continually get the lock because it was hot in _its_ caches, and all 
other CPU's would almost always fail.

In that situation, re-enabling interrupts can be critical, just because 
they might be disabled for many thousands of iterations of the spinlock 
being busy on another CPU.

With the ticket locks, you'd need to have a _huge_ machine in order to 
ever see that kind of situation (ie now you'd need to see thousands of 
CPU's all trying to get that lock in order to see latencies that are a 
thousand iterations of whatever happens inside the spinlock). And in 
practice, with good locking, you should never see that. If you actually 
have thousands of CPU's (or even hundreds) all wanting the same lock at 
the same time, you're just going to have to fix the locking.

			Linus
