From: Robin Holt <holt@sgi.com>
Date: Tue, 15 Feb 2005 19:11:20 +0000
Subject: Re: [rfc] generic allocator and mspec driver
Message-Id: <20050215191119.GB24401@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16897.9640.160896.31584@jaguar.mkp.net>
In-Reply-To: <16897.9640.160896.31584@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Feb 15, 2005 at 10:04:49AM -0800, David Mosberger wrote:
> >>>>> On 15 Feb 2005 03:43:10 -0500, Jes Sorensen <jes@wildopensource.com> said:
> 
> >>>>> "Tony" = Luck, Tony <tony.luck@intel.com> writes:
> 
>   Tony> Is ia64 the only architecture that has uncached vs. cached
>   Tony> access issues?  If so, the PG_arch_1 might have to be the
>   Tony> solution, but surely others have cache coherence problems too
>   Tony> if there are mixed cacheable and uncacheable access to the
>   Tony> same memory?  In which case a new generic bit would be more
>   Tony> appropriate.
> 
>   Jes> None of the ones I know well have this problem, but I have
>   Jes> little knowledge about this level of stuff on most
>   Jes> architectures. The ones that could have issues would probably
>   Jes> be like PPC, PARISC and maybe Alpha .....
> 
> Well, any CPU that allows overlapping mappings and does _any_ sort of
> speculative accesses will have a problem.  The only question is
> whether you'll get an explicit error notification (e.g., MCA) or
> silent data corruption.

We saw many silent data corruptions. The SN2 hardware will give an
MCA if both types of references are made by the cpu at about the
same time, but that depends on both transactions being on the bus
in close relationship to each other.

Robin
