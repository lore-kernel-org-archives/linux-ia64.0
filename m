From: Christoph Lameter <christoph@lameter.com>
Date: Tue, 13 Jul 2004 01:19:06 +0000
Subject: Re: Timer patches (nsec support + fastcalls for gettod/clock_gettime
Message-Id: <Pine.LNX.4.58.0407121750470.7187@server.home>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0407091545250.5720@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0407091545250.5720@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 12 Jul 2004, David Mosberger wrote:

> Preserved registers _always_ need to be preserved by fsys-handlers.
> If you avoid using preserved predicates, there is no need to save
> them.  See the software conventions & runtime architecture guide for
> details (as far as predicate registers go, p1-p5 and p16-p63 are
> "preserved").

Aah! Wonder why my code was able to survive all these tests. Will make
sure that I follow those guidelines immediately.

> The kernel-internal gettimeofday() can return anything it wants (as
> long as all platforms do it consistently.  As to whether or not that's
> a good idea, i don't really care (but I do not think it's reasonable
> or necessary to have two platform routines with the only difference
> being whether they return timeval or timespec).

There is do_gettimeofday which is used all over the place and many drivers
rely on do_gettimeofday returning usecs and not nsecs. I have not seen
gettimeofday. Maybe I can introduce a kernel internal gettimeofday?
Rename getnstimeofday to gettimeofday?? Invocations of do_gettimeofday
then will be a legacy case.

>   Christoph> But do_gettimeofday is used a gazillion times all over
>   Christoph> the linux sources and changing that would result in a
>   Christoph> huge patch that might not be acceptable either.
>
> That can be OK, if there is agreement that it's The Right Thing.
> Hence it's definitely something that should be done in coordination
> with George and lkml in general (and it also needs to be done
> separately from the ia64-specific changes; figuring out how to break
> the patch up is one thing we'll need to sort out eventually).

How do we obtain that agreement?

The problem is that I cannot obtain nsec accuracy without modifying the C
clock_gettime function in kernel/posix-timer.c. I could separate the timer
interpolator stuff from the ns resolution issues. But both are only
effective together.
