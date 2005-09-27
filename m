From: David Mosberger-Tang <David.Mosberger@acm.org>
Date: Tue, 27 Sep 2005 01:20:08 +0000
Subject: Re: [PATCH 0/4] V4 ia64 SPARSEMEM
Message-Id: <ed5aea43050926182024b7e66c@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050922161418.GW16066@localhost.localdomain>
In-Reply-To: <20050922161418.GW16066@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 9/26/05, Luck, Tony <tony.luck@intel.com> wrote:

> >Long term should SPARSEMEM become the default and DISCONTIG+VIRTUAL_MEM_MAP
> >be obsoleted then we could remove the config files.
>
> If benchmarks show no difference, then I'll consolidate the
> configuration options.  I still think that VIRTUAL_MEM_MAP
> has a great deal of elegance to it ... auto-sizing to just
> about any degree of sparseness, but I think we need to
> simplify.

Benchmarks cannot prove the absence of a performance difference in
*general*, they can only do that for specific tests and workloads. 
So, unless SPARSEMEM actually performs *better* on some benchmarks
(and no worse on others), the proper course seems to be to stick with
VIRTUAL_MEM_MAP where SPARSEMEM isn't needed.

I have voice my objection in the past to Bob's suggestion that
SPARSEMEM should replace VIRTUAL_MEM_MAP and since then I haven't seen
any convincing argument why that should be the case, so I do not
understand why Bob keeps bringing that up.

  --david
--
Mosberger Consulting LLC, voice/fax: 510-744-9372,
http://www.mosberger-consulting.com/
35706 Runckel Lane, Fremont, CA 94536
