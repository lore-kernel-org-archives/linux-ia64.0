From: "Van Maren, Kevin" <kevin.vanmaren@unisys.com>
Date: Fri, 08 Nov 2002 18:05:30 +0000
Subject: RE: [Linux-ia64] reader-writer livelock problem
Message-Id: <marc-linux-ia64-105590709805368@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805355@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805355@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Absolutely you should minimize the locking contention.
However, that isn't always possible, such as when you
have 64 processors contending on the same resource.
With the current kernel, the trivial example with reader/
writer locks was having them all call gettimeofday().
But try having 64 processors fstat() the same file,
which I have also seen happen (application looping,
waiting for another process to finish setting up the
file so they can all mmap it).

What MCS locks do is they reduce the number of times
the cacheline has to be flung around the system in
order to get work done: they "scale" much better with
the number of processors: O(N) instead of O(N^2).

Kevin

-----Original Message-----
From: Matthew Wilcox
To: Van Maren, Kevin
Cc: 'Linus Torvalds '; 'Jeremy Fitzhardinge '; 'William Lee Irwin III ';
'linux-ia64@linuxia64.org '; 'Linux Kernel List '; 'rusty@rustcorp.com.au ';
'dhowells@redhat.com '; 'mingo@elte.hu '
Sent: 11/8/02 12:52 PM
Subject: Re: [Linux-ia64] reader-writer livelock problem

On Fri, Nov 08, 2002 at 11:41:57AM -0600, Van Maren, Kevin wrote:
> processor to acquire/release the lock once.  So with 32 processors
> contending for the lock, at 1us per cache-cache transfer (picked

if you have 32 processors contending for the same spinlock, you have
bigger problems.

-- 
Revolutions do not require corporate support.

