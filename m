From: Robin Holt <holt@sgi.com>
Date: Tue, 01 Nov 2005 12:13:09 +0000
Subject: Re: [RFC] 4-level page table directories.
Message-Id: <20051101121309.GA32692@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051027041709.GA13193@attica.americas.sgi.com>
In-Reply-To: <20051027041709.GA13193@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Oct 28, 2005 at 07:18:16PM -0700, David Mosberger-Tang wrote:
> On 10/28/05, Luck, Tony <tony.luck@intel.com> wrote:
> 
> > The worst-case loser from this might be a benchmark that runs
> > oodles of small processes (partly from the overhead of the extra
> > page, and partly because I suspect that fork/exec/exit might see
> > the most impact).  So I'd like to see some AIM7 numbers too.
> 
> And I would want to see numbers for the "RANDOM" benchmark (from the
> HPCC benchmark suite) for huge data sets (multi-gigabyte; something
> big enough such that not even the page tables fit in the caches).

I can't seem to find a single benchmark which is showing an appreciable
(actually, any) difference.  I finally sat down with Jack yesterday and we
ran what he thought would be a worst-case benchmark.  His test would map
a page at a strided offset throughout the address space and time how long
it would take to access all the pages.  We found absolutely no difference.

We then started discussing this.  For a normal application with the
same virtual address requirements run on a 4 versus a 3 level page table,
we would end up with, at most five additional pages of page tables with
a single cache-line used in each.  Those cachelines would be frequently
used and therefore remain active.  This would essentially eliminate the
second point in ivt.S where you would expect a stall.  Jack guessed we
would be introducing an additional delay of 2 to 5 clock cycles.

I had started to work up a patch which would have allowed CONFIG of
2 to 4 levels of page tables, but I continue to see that as futile.
Jack thought it might be a good idea to at least allow the config of 3
or 4 to make it easier to sort out any delays we may see in the future,
but neither of us could come up with a worst-case scenario which actually
shows a difference.

I am trying to get time on one of our larger machines today to run the
RandomAccess benchmark (as well as some help from somebody that has run
these before).  Is there a certain number of cpus you would like this
run on or is a 64p box adequate?

Given the benchmark results I have seen so far, when I introduce the
CONFIG for levels, does anybody have any objection to setting it to 4
by default?

Thanks,
Robin Holt
