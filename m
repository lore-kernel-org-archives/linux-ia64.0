From: "Van Maren, Kevin" <kevin.vanmaren@unisys.com>
Date: Mon, 29 Jul 2002 21:05:35 +0000
Subject: RE: [Linux-ia64] Linux kernel deadlock caused by spinlock bug
Message-Id: <marc-linux-ia64-105590701905845@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905843@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905843@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> On Mon, Jul 29, 2002 at 03:37:17PM -0500, Van Maren, Kevin wrote:
> > I changed the code to allow the writer bit to remain set even if
> > there is a reader.  By only allowing a single processor to set
> > the writer bit, I don't have to worry about pending writers starving
> > out readers.  The potential writer that was able to set the 
> writer bit
> > gains ownership of the lock when the current readers finish.  Since
> > the retry for read_lock does not keep trying to increment the reader
> > count, there are no other required changes.
> 
> however, this is broken.  linux relies on being able to do
> 
> read_lock(x);
> func()
>   -> func()
>        -> func()
>             -> read_lock(x);
> 
> if a writer comes between those two read locks, you're toast.
> 
> i suspect the right answer for the contention you're seeing 
> is an improved
> get_timeofday which is lockless.

Recursive read locks certainly make it more difficult to fix the
problem.  Placing a band-aid on gettimeofday will fix the symptom
in one location, but will not fix the general problem, which is
writer starvation with heavy read lock load.  The only way to fix
that is to make writer locks fair or to eliminate them (make them
_all_ stateless).

Recursive read locks also imply that you can't replace them with
a "normal" spinlock, which would also solve the problem (although
they do _not_ scale under contention -- something like O(N^2)
cache-cache transfers for N processors to acquire once).

There are ways of fixing the writer starvation and allowing recursive
read locks, but that is more work (and heavier-weight than desirable).
How pervasive are recursive reader locks?  Should they be a special
type of reader lock?

Kevin

