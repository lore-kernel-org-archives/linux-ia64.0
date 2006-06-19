From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Mon, 19 Jun 2006 08:42:43 +0000
Subject: Re: [discuss] Re: FOR REVIEW: New x86-64 vsyscall vgetcpu()
Message-Id: <44966383.1030006@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <200606140942.31150.ak@suse.de> <200606161740.18611.ak@suse.de> <Pine.LNX.4.64.0606161615450.23743@turbotaz.ourhouse> <200606170855.49123.ak@suse.de>
In-Reply-To: <200606170855.49123.ak@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@suse.de>
Cc: discuss@x86-64.org, Chase Venters <chase.venters@clientec.com>, Brent Casavant <bcasavan@sgi.com>, Jes Sorensen <jes@sgi.com>, Tony Luck <tony.luck@intel.com>, linux-kernel@vger.kernel.org, libc-alpha@sourceware.org, vojtech@suse.cz, linux-ia64@vger.kernel.org

Brent Casavant wrote:

> To this last point, it might be more reasonable to map in a page that
> contained a new structure with a stable ABI, which mirrored some of
> the task_struct information, and likely other useful information as
> needs are identified in the future.  In any case, it would be hard
> to beat a single memory read for performance.
> 
> Cache-coloring and kernel bookkeeping effects could be minimized if this
> was provided as an mmaped page from a device driver, used only by
> applications which care.  This does work somewhat contrary to the idea of
> getting support into glibc, unless glibc only used this capability when
> asked to through some sort of environment variable or other run-time
> configuration.

Quite O.K. for me.

Andi Kleen wrote:

>>Well, if every process had a page of its own, what would the context
>>switch overhead be?

> For process zero, for thread quite high on x86 because you
> would need per CPU page tables. Doing that would be extremly
> nasty because you would potentially need to allocate a new
> set of page tables every time the process is scheduled to a new
> CPU it hasn't run on before.

Probably I have not explained it correctly:
- The "information page" (that includes the current CPU no.) is not a
  per CPU page
- This page is just another page that is mapped at a "well known" user
  virtual address (for those who are interested in)
- As you do not do any special action for each user page on context
  switch, there is nothing to to this page either
- The scheduler sometimes migrates a task, then it updates the
  the current CPU number on the "information page"

> My reference was more to high suggestion of keeping a second version 
> of task_struct for export. That would require changing everything
> in task struct that is changed on switch_to and should be exported
> in the other function too.

It depends on what else can be in this "information page".
As for the current CPU no., you need a single store on each task migration.

Thanks,

Zoltan
