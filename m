From: Andi Kleen <ak@suse.de>
Date: Tue, 14 Dec 2004 19:13:48 +0000
Subject: Re: [PATCH 0/3] NUMA boot hash allocation interleaving
Message-Id: <20041214191348.GA27225@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.SGI.4.61.0412141140030.22462@kzerza.americas.sgi.com> <9250000.1103050790@flay>
In-Reply-To: <9250000.1103050790@flay>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Brent Casavant <bcasavan@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-ia64@vger.kernel.org, ak@suse.de

On Tue, Dec 14, 2004 at 10:59:50AM -0800, Martin J. Bligh wrote:
> > NUMA systems running current Linux kernels suffer from substantial
> > inequities in the amount of memory allocated from each NUMA node
> > during boot.  In particular, several large hashes are allocated
> > using alloc_bootmem, and as such are allocated contiguously from
> > a single node each.
> 
> Yup, makes a lot of sense to me to stripe these, for the caches that

I originally was a bit worried about the TLB usage, but it doesn't
seem to be a too big issue (hopefully the benchmarks weren't too
micro though)

> didn't Manfred or someone (Andi?) do this before? Or did that never
> get accepted? I know we talked about it a while back.

I talked about it, but never implemented it. I am not aware of any
other implementation of this before Brent's.

-Andi
