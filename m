From: "Boehm, Hans" <hans_boehm@hp.com>
Date: Tue, 06 Jun 2000 17:08:20 +0000
Subject: RE: [Linux-ia64] Two IA-64 Linux bugs
Message-Id: <marc-linux-ia64-105590678205121@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205116@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205116@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

We also had problems around here with pthread_cond_wait.  The glibc version
we were using was used a linuxthreads snapshot taken at a bad time.
Pthread_cond_wait checked that the current thread owned the mutex.
Unfortunately, it did so even for "fast" mutexes, for which the owner field
wasn't set.

If this is the problem, I would guess that you should be able to avoid it by
using recursive or checking mutexes.  The problem is hopefully very
temporary, since the glibc on sourceware exhibited this problem for only a
day.

Hans

> Bug #1: pthread_cond_wait sometimes returns EINVAL (22).
> Run the first attachment (pingpong.c) repeatedly.
> Note that this test doesn't call pthread_cond_destroy
> so it is impossible that we are waiting on a destroyed
> condition variable.  This failure is intermittent so you
> may need to try many times to reproduce it.
> 


