From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 28 Jun 2001 00:18:43 +0000
Subject: RE: [Linux-ia64] Re: pthread_mutex_lock sometimes fails on Linux
Message-Id: <marc-linux-ia64-105590693005794@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005788@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005788@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This sounds similar to a problem that I saw a few weeks
ago.  In my case threads would spin for an inordinate
amount of time in __pthread_lock() because re-reading of
the __status field was optimised out of the loop (it isn't
declared as volatile).  Newer versions of glibc (2.2.2 IIRC)
have some __asm() magic in the loop to force the re-read (the
glibc folks didn't want to make the __status field volatile
because of lots of other pointer casting changes that would
have been needed).

See if a newer glibc helps with your problem too.

-Tony Luck

-----Original Message-----
I slightly misstated the problem.  Here is what actually happens:
Four threads have entered a barrier (my own C code).  Within the barrier,
they call pthread_mutex_lock and increment a counter while holding the lock.
Three threads are waiting on the counter, whose value is three, to go to
four.  The fourth CPU is looping in the kernel in cpu_idle.  I don't know
how it got there, but probably it has something to do with calling
pthread_mutex_lock.


