From: Sean Griffin <sean@nwssmail01.jf.intel.com>
Date: Tue, 30 Jul 2002 22:48:36 +0000
Subject: Re: [Linux-ia64] Linux kernel deadlock caused by spinlock bug
Message-Id: <marc-linux-ia64-105590701905860@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905843@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905843@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Mr. Lewis' solution fails to address the scenario of recursively
taken read locks.  Since in that case, the thread taking the lock
already holds the lock, running some nops doesn't really give
another thread the possibility of acquiring the write lock.  So
it works out to be the same situation only with a bunch of nops
executed in the critical path.


-Sean Griffin




> On Tue, 30 Jul 2002, Russell Lewis wrote:
> 
> > IDEA: Implement a read/write "bias" field that can show if a lock has 
> > been gained many  times in succession for either read or write.  When 
> > locks of the opposite type are attempting (and failing) to get the lock, 
> > back off the other users until starvation is relieved.
> > 
> 
> You need to gain a lock just to read the bias field. You can't read
> something that somebody else will change while you are deciding
> upon what you read. It just can't work.
> 
> If we presume that it did work. What problem are you attempting
> to fix?  FYI, there are no known 'lock-hogs'. Unlike a wait on
> a semaphore, where a task waiting will sleep (give up the CPU), a
> deadlock on a spin-lock isn't possible. A task will eventually
> get the resource. Because of the well-known phenomena of "locality",
> every possible 'attack' on the spin-lock variable will become
> ordered and the code waiting on the locked resource will get
> it in a first-come-first-served basis. This, of course, assumes
> that the code isn't broken by attempts to change the natural
> order.
> 
> Cheers,
> Dick Johnson
> Penguin : Linux version 2.4.18 on an i686 machine (797.90 BogoMips).
> The US military has given us many words, FUBAR, SNAFU, now ENRON.
> Yes, top management were graduates of West Point and Annapolis.
> 
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64


