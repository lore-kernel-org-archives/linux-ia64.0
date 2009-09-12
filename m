From: Andi Kleen <andi@firstfloor.org>
Date: Sat, 12 Sep 2009 21:23:52 +0000
Subject: Re: [RFC] Convert ia64 spinlocks to use "tickets"
Message-Id: <87ab0zhn6f.fsf@basil.nowhere.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <4aa9e16649286264@agluck-desktop.sc.intel.com>
In-Reply-To: <4aa9e16649286264@agluck-desktop.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

"Luck, Tony" <tony.luck@intel.com> writes:
>
> But the patch went in because the ticket locks were only very slightly
> slower in the uncontended case, and they did solve a real problem
> for a common two socket platform where the lack of fairness allowed the

It was a eight socket platform. I'm not aware of any unfair two socket
platforms.

> cores on one socket to freeze out the cores on the other socket for
> extremely long periods.

Very long as a minute in extreme corner cases. So the motivation was more
to limit the worst case than to tune a common case.

BTW the main problem of ticket locks is that they tend to cooperate
badly with hypervisors, they can run into bad convoying issues with
the vcpu scheduler. So you probably should have a way to turn them
off.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.
