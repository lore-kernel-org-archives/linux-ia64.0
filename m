From: "Luck, Tony" <tony.luck@intel.com>
Date: Sat, 12 Sep 2009 23:39:17 +0000
Subject: RE: [RFC] Convert ia64 spinlocks to use "tickets"
Message-Id: <57C9024A16AD2D4C97DC78E552063EA3E0564BE9@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4aa9e16649286264@agluck-desktop.sc.intel.com>
In-Reply-To: <4aa9e16649286264@agluck-desktop.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> It was a eight socket platform. I'm not aware of any unfair two socket
> platforms.

I got the two socket information from Nick's git commit comment:

commit 314cdbefd1fd0a7acf3780e9628465b77ea6a836
Author: Nick Piggin <npiggin@suse.de>
Date:   Wed Jan 30 13:31:21 2008 +0100

    x86: FIFO ticket spinlocks

...

On an 8 core (2 socket) Opteron, spinlock unfairness is extremely noticable,
with a userspace test having a difference of up to 2x runtime per thread, and
some threads are starved or "unfairly" granted the lock up to 1 000 000 (!)
times. After this patch, all threads appear to finish at exactly the same
time.

> BTW the main problem of ticket locks is that they tend to cooperate
> badly with hypervisors, they can run into bad convoying issues with
> the vcpu scheduler. So you probably should have a way to turn them
> off.

In the paravirtualized case the spinlock contention case should be a
hypercall.

Yes, I see that in the native case the vcpu scheduler has less to worry
about ... any spinner that it picks can acquire the lock with traditional
spin locks ... whereas with ticket locks if it picks the wrong one it
will just spin uselessly waiting for a "now serving" value to show up
that can't happen until all the vcpus that hold lower number tickets
have been run (in order!).

-Tony
