From: Rich Altmaier <richa@sgi.com>
Date: Mon, 12 Jul 2004 22:08:20 +0000
Subject: Re: Consistency problem on IPF
Message-Id: <40F30BD4.2060209@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40F2562C.10208@inria.fr>
In-Reply-To: <40F2562C.10208@inria.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


We had a slight look at this code and notice the leading dimension of
the array is a power of 2.  This is often problematic
with a weaker compiler like gcc.  We used icc (Intel's) and saw
very repeatable execution times, and significantly better time.
Cache line conflicts (which page coloring addresses) can be
caused by a case like this:
3 arrays, with loop unrolling, creates a strain even on the
8-way associative cache.   The compiler can control how many
of these ways are being consumed.
So far gcc hasn't shown many cases of good execution time, as I see it.

All of this said, we do see cases where we would like some page
coloring control by the OS.  But it is also the case that
you will get far, far better results by first deciding to use the
Intel compiler (that is the largest influence on results).

Many of the features we persue are indeed aimed at achieving deterministic
performance.  Customers do like it.  Every time a job runs slower than
a prior run, there is a feeling of losing something.
I would also recommend you consider running your jobs on an Altix system!

Thanks, Rich



David Mosberger wrote:

>>>>>>On Mon, 12 Jul 2004 14:01:15 +0200, Marc Gonzalez-Sigler <marc.gonzalez-sigler@inria.fr> said:
> 
> 
>   Marc> (For the record, I tried gcc-3.3.4 and orcc-2.1)
> 
> For floating-point stuff, you'll definitely want to try the Intel compiler.
> It's a free download for the unsupported/non-commercial version.
> 
> As others have pointed out, for matrix multiply, you'll definitely
> want to use a hand-tuned version as is available in several math
> libraries (yeah, I realize you are not really after matrix multiply).
> 
>   Marc> Perhaps I was not clear enough. I used matrix-matrix multiply
>   Marc> only as an example. My real problem is the non-deterministic
>   Marc> behavior.
> 
> Page-coloring can make things more deterministic, at the expense of making
> _everything_ go slower.  If you search the net, you should be able to
> find a page-coloring module.  We have experimented with it in the past
> and it did its job, but it's overall impact was to slow things down, so
> it's not a great solution.
> 
> The other thing you could do on Linux is use huge pages.  That will
> mitigate/eliminate the effect of page coloring (and also reduce TLB
> pressure).
> 
>   Marc> Say I tile the main loop nest. I want to compare the execution
>   Marc> time of the original, untiled program and the execution time
>   Marc> of the modified, tiled program.
> 
>   Marc> If the original version completes in 1 second 80% of the time,
>   Marc> and the modified version completes in 0.5 seconds 80% of the
>   Marc> time, but 2 seconds 20% of the time, then, if I am unlucky, I
>   Marc> might eliminate an excellent candidate. This is why I need the
>   Marc> execution times of a given program to be consistent.
> 
> I think you have to allow for the fact that modern CPUs (and OSes) do
> not really offer deterministic performance.  And don't expect things
> to get better.  Dynamic power throttling, multi-threading, etc., will
> make performance analysis very "interesting".
> 
> 	--david

