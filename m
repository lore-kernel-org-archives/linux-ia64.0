From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Fri, 14 Sep 2007 10:47:12 +0000
Subject: __down() fails to provide with acquisition semantics
Message-Id: <46EA66B0.1000900@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070807172458.59931ef2.kamezawa.hiroyu@jp.fujitsu.com> <20070807172648.4590c3dd.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070807172648.4590c3dd.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

I have got a concern about "__down()".
Can someone explain me, please, how it is assumed to work?

Apparently, "__down()" fails to provide with acquisition semantics
in certain situations.

Let's assume the semaphore is unavailable and there is nobody
waiting for it.

The next requester enters the slow path.

Let's assume the owner of the semaphore releases it just before
the requester would execute the line:

   if (!atomic_add_negative(sleepers - 1, &sem->count)) {

Therefore the loop gets broken, the requester returns without
going to sleep.

   atomic_add_negative():
	atomic_add_return():
		ia64_fetch_and_add():
			ia64_fetchadd(i, v, rel)

At least on ia64, "atomic_add_negative()" provides with release
semantics.

"remove_wait_queue_locked()" does not care for acquisition semantics.
"wake_up_locked()" finds an empty list, it does nothing.
"spin_unlock_irqrestore()" does release semantics.

The requester is granted the semaphore and s/he enters the critical
section without making sure that the memory accesses s/he wants to
issue in the critical section cannot be made globally visible before
"atomic_add_negative()" is.

We need an acquisition semantics (at least) before entering any
critical section. Should not we have something like:

   if (atomic_add_acq(sleepers - 1, &sem->count) /* ret: new val */ >= 0){

"atomic_add_acq()" would provide with acquisition semantics in
an architecture dependent way.
I think it should be made more explicit that this routine should
provide with the architecture dependent memory fencing.


What is the use of the "wake_up_locked(&sem->wait)"?
The other requester woke up, will find the semaphore unavailable...


Another question: is there any reason keeping an ia64 version when
lib/semaphore-sleepers.c and arch/ia64/kernel/semaphore.c do not
really differ?


Thanks,

Zoltan Menyhart
