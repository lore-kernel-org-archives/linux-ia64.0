From: Russell Lewis <spamhole-2001-07-16@deming-os.org>
Date: Wed, 31 Jul 2002 17:37:37 +0000
Subject: Re: [Linux-ia64] Linux kernel deadlock caused by spinlock bug
Message-Id: <marc-linux-ia64-105590701905867@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905843@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905843@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Sean Griffin wrote:

>
>Mr. Lewis' solution fails to address the scenario of recursively
>taken read locks.  Since in that case, the thread taking the lock
>already holds the lock, running some nops doesn't really give
>another thread the possibility of acquiring the write lock.  So
>it works out to be the same situation only with a bunch of nops
>executed in the critical path.
>
>
>-Sean Griffin
>
Right.  It's not a very good solution, just one of many hacks that might 
work :(

What if we kept a value (in per-CPU or per-thread memory) that was a 
pointer to the last r/w lock we'd gained?  When we release ANY r/w lock, 
we could blindly initialize the "lastLock" pointer back to NULL.  Then 
we have a very quick (i.e. not very good) heuristic for detecting 
recursive locks; if the "lastLock" pointer equals the pointer to the 
thing you're about to try to lock, then you know that you already hold 
it and are about to grab it recursively...otherwise, you fall back to 
other routines.

If you really wanted, you could keep multiple pointers per CPU (exact 
number tunable by a kernel #define), and on release only clear the one 
you are actually releasing.  Most builds, I imagine, wouldn't need more 
than just a single pointer, though.


