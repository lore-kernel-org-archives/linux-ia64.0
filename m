From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 04 Mar 2005 19:58:21 +0000
Subject: RE: [Patch 0/3] Page table quicklist fixups Rev 3.
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F03037C1C@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050303212359.GA732@lnx-holt.americas.sgi.com>
In-Reply-To: <20050303212359.GA732@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Robin Holt wrote:
>The comment was left from the earlier set of patches where it
>had a single role.  In that patch, we picked a number of pages to
>free, freed that many, and went on with life expecting the next
>pass to free a group.  Since the changes gave it a more complex
>role and the code was not that complex, I figured I would remove
>the comment and let anybody planning on changing it in the future
>read the code to figure out the two roles.

Why not just have two defines?

#define MAX_QUICKLIST_BATCH_FREE	16

#define NODE_FREE_PAGES_SHIFT 4

The first may be obvious enough to not need a comment for people to
figure it out.  The second either needs a better name, or a comment
(or both).  Also ... is "4" the right value?  That implies that you
are expecting to only manage 16 user level data pages for each pte
(which sounds quite plausible for cat/ls/cp/mail sized applications,
but larger memory hungry number-crunching applications hopefully see
a better ratio of data pages to page-tables).  If you have data (I
only have guesses) then I'd like a snapshot ... but I'm not trying
to open a new can of worms here, I'm OK with the "4" value (I just
want it properlay named and commented).

>> I'm also a bit uncomfortable with:
>> 
>> +		preempt_enable();
>> +		preempt_disable();
>> 
>> For a kernel with CONFIG_PREEMPT=n, this is a no-op ... so if there
>> is a ton of extra pages on the quicklist, we'll loop freeing 16 at
>> a time and re-computing how many to free, with no pause to take a
>> breath (or a clock tick).
>
>What do you want me to do.  I don't see anywhere else in the kernel
>that these two lines are directly adjacent.  Most places that do
>the disable/enable are in a function which does one thing.  That is
>occasionally contained inside a larger loop.  We can not do that since
>part of our outer loop control is based on the per_cpu variable we are
>expecting to not change.  I suppose I could elminitate the 
>disable/enable entirely.  I haven't thought all the way through the possibilities,
>but I would guess we could free a couple extra pages, but who cares.

The fact that this doesn't happen elsewhere might be a sign that
we are doing something strange ... if this was normal, then there
would be a prettier macro that did the enable/disable.  Getting
the exactly right number of pages freed isn't my goal (since there
is no way to know what the exactly right number is ... we just need
to do something approximately right, that doesn't have any truly
awful boundary cases.

>You tell me what to do.

At the moment I'm hoping somebody smarter will chime into this thread
(either to point out a great solution, or to tell me that I'm a dork
and this code is perfectly reasonable, so I should quit quibbling).

Overall the patch is great ... it's solving a real problem in an elegant
way.  It's just this little corner of how to shrink the quicklists that
I'm trying to get right.

-Tony
