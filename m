From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 11 Sep 2009 22:22:54 +0000
Subject: RE: [RFC] Convert ia64 spinlocks to use "tickets"
Message-Id: <57C9024A16AD2D4C97DC78E552063EA3E05649B6@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4aa9e16649286264@agluck-desktop.sc.intel.com>
In-Reply-To: <4aa9e16649286264@agluck-desktop.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>> Early last year x86 changed their spinlock implementation to
>> use a fair "ticket" system (just like the one at deli counter
>> in the grocery store).  Here is the same conversion for ia64.
>
> A naieve comment, but doesn't a desire to implement "fairness" suggest lock 
> contention that aught to be addressed?

No, that's a good point.  I was a bit surprised that the ticket patch
went into x86 with so little fuss given the long standing attitude that
the fix for lock contention problems was not to go tweaking the locking
code to make it faster ... but to go and do possibly major surgery on the
code that was using to locks to reduce the contention by changing the
algorithm or the locking scope, or moving to lockless algorithms when
possible.

But the patch went in because the ticket locks were only very slightly
slower in the uncontended case, and they did solve a real problem
for a common two socket platform where the lack of fairness allowed the
cores on one socket to freeze out the cores on the other socket for
extremely long periods.

I do have a data point for the performance of ticket locks on ia64. For
kernel compiles (using "make -j12" on a 4-socket, 8-core, 16-thread
system), the impact is in the noise.  Mean time to build across 300
builds was 0.2% slower with ticket locks ... but the run to run variation
on these builds was 1.6% (for +/- one standard deviation).

-Tony
