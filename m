From: Jim Wilson <wilson@specifixinc.com>
Date: Fri, 07 May 2004 07:48:46 +0000
Subject: Re: [PATCH] new ".serialize" gas directive
Message-Id: <1083916127.1073.158.camel@leaf.tuliptree.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <16537.51724.854691.934006@napali.hpl.hp.com>
In-Reply-To: <16537.51724.854691.934006@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 2004-05-06 at 16:47, David Mosberger wrote:
> Isn't it true that GCC never produces a NaT on its own and never uses
> uninitialized registers?

Currently, we never intentionally produce NaTs.  However, hopefully
someday we will, so we should be careful about things like this.

I am not sure about the uninitialized register thing.  It used to be the
case that you could get writes to uninitialized registers if you had an
uninitialized variable in the source.  Of course, in that case, the
program is broken anyways.  However, I think this might have been fixed
for other non-IPF reasons.  I couldn't get an unitialized register use
with a trivial example.

>  Perhaps GCC
> should assert that p34 and p35 are mutually exclusive (effectively
> asserting that r22 is not a NaT)?

There is no trivial way to do this.  At the moment, gcc only emits the
mutex directive if a predicate register is live across a basic block. 
That is the only case that gas can't figure out on its own.

New code would have to be written to handle this case.  We might just
have to emit mutex directives for every compare which will clutter up
the assembly language.  That would be unfortunate, but maybe it is
unavoidable for now.

I don't have a lot of time for IA-64 gcc work at the moment.  It might
be useful to have a gcc bug report for this so we don't lose track of
it.
-- 
Jim Wilson, GNU Tools Support, http://www.SpecifixInc.com

