From: "Adriano Galano" <adriano@satec.es>
Date: Mon, 05 May 2003 09:08:07 +0000
Subject: RE: [Linux-ia64] benchmarking results
Message-Id: <marc-linux-ia64-105590723705635@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705621@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705621@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Steve:

> > >>>>> On Wed, 30 Apr 2003 18:17:45 +0200, "Adriano Galano"
> <adriano@satec.es> said:
> >
> >   Adriano> We need to find some reference of SMP
> scalability on Linux
> >   Adriano> scheduler. For 1, 2, 4 and 8 processor. How "lineal" is
> >   Adriano> this scalability? Does Linux perform well en 4
> or 8 Itanium
> >   Adriano> 2 architecture?
> >
> > David Mosberger wrote:
> > There is no single answer to the scalability question.  It totally
> > depends on what application you're running.  SGI has shown that
> > certain apps scale very nicely all the way to 64 CPUs on their Altix
> > box.  Kernel-intensive apps won't scale that far, but even
> there there
> > is some evendice of very nice scaling.  ...
>
> Hi Adriano,
>
> As David points out, there's a lot of factors that can affect
> scalability
> results for a particular workload.  If you haven't already,
> you might want
> to check out the following from the February 2003 issue of
> Linux Journal
> magazine: http://linuxjournal.com/article.php?sidd40, which
> provides more
> background on the SGI Altix system along with some scaling
> and benchmark results.
>

Thanks for the reference.

Maybe in all the cases I can see NUMA architectures and not find references
related to what kind of scheduler was used older sched, O(1) or HT? The
limits of the bricks for SMP are 4 proc, how could I assume linear
scalability for 8 proc having memory latency accesing the others bricks
through R-Brick maybe?

Regards,

-Adriano

> Hope that helps.
>
> --steve


