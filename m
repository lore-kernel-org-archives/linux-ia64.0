From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 29 Sep 2009 17:53:34 +0000
Subject: RE: [git pull] ia64 changes
Message-Id: <57C9024A16AD2D4C97DC78E552063EA3E2EA3B8B@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> That said, the 8% slowdown sounds like a real problem. Maybe Tony's 
> original version (perhaps with a "ld.bias" to get the initial load to try 
> to get exclusive ownership) is worth the size expansion

The 8%/16% numbers are absolute worst case values.  They are based on
the time to acquire and release a lock in the case where the lock is
resident in the L1 cache of the cpu running the code.  So I'm looking
at 24 cycles for the old xchg-based version. 26 cycles for 8-byte ticket
locks and 28-cycles for 4-byte ticket locks.

The real world is likely to be much kinder.  If the lock is being
acquired by different cpus, then we'll have to go to memory (or remote
cache, which is just as bad) to get the lock. Then the 2-4 extra cycles
will be a much tinier percentage of the total.  Even if the lock is being
mostly used by a single cpu with only occasional remote access, it still
isn't likely to live in the L1 cache ... so we'd see another 14 cycles if
we had to pull it back into L1 from L3.

Any feel for how much memory this is going to cost?  Although there is
a spinlock inside "struct page" it is buried in a union with a larger
structure. So changing from 4 to 8 bytes makes no difference to the
total size of the structure.  For statically declared locks the
difference reported by "size vmlinux" is laughably small (~4KB!)

What will be the big areas of growth? dentry? inode? Something off
in networking?

-Tony
