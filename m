From: Matthew Wilcox <willy@debian.org>
Date: Fri, 08 Nov 2002 19:19:07 +0000
Subject: Re: [Linux-ia64] reader-writer livelock problem
Message-Id: <marc-linux-ia64-105590709805373@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805355@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805355@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Nov 08, 2002 at 12:05:30PM -0600, Van Maren, Kevin wrote:
> Absolutely you should minimize the locking contention.
> However, that isn't always possible, such as when you
> have 64 processors contending on the same resource.

if you've got 64 processors contending on the same resource, maybe you
need to split that resource up so they can have a copy each.  all that
cacheline bouncing can't do your numa boxes any good.

> With the current kernel, the trivial example with reader/
> writer locks was having them all call gettimeofday().

i hear x86-64 has a lockless gettimeofday.  maybe that's the solution.

> But try having 64 processors fstat() the same file,
> which I have also seen happen (application looping,
> waiting for another process to finish setting up the
> file so they can all mmap it).

umm.. the call trace:

sys_fstat
|-> vfs_fstat
|   |-> fget
|	|-> read_lock(&files->file_lock)
|   |-> vfs_getattr
|	|-> inode->i_op->getattr
|	|-> generic_fillattr
|-> cp_new_stat64
    |-> memset
    |-> copy_to_user

so you're talking about contention on files->file_lock, right?  it's really
not the kernel's fault that your app is badly written.  that lock's private
to process & children, so it's not like another application can hurt you.

> What MCS locks do is they reduce the number of times
> the cacheline has to be flung around the system in
> order to get work done: they "scale" much better with
> the number of processors: O(N) instead of O(N^2).

yes, but how slow are they in the uncontended case?

-- 
Revolutions do not require corporate support.

