From: Christoph Hellwig <hch@infradead.org>
Date: Mon, 29 Apr 2019 20:09:57 +0000
Subject: Re: DISCONTIGMEM is deprecated
Message-Id: <20190429200957.GB27158@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190419094335.GJ18914@techsingularity.net>
 <20190419140521.GI7751@bombadil.infradead.org>
 <0100016a461809ed-be5bd8fc-9925-424d-9624-4a325a7a8860-000000@email.amazonses.com>
 <25cabb7c-9602-2e09-2fe0-cad3e54595fa@linux.ee>
 <20190428081353.GB30901@infradead.org>
 <3908561D78D1C84285E8C5FCA982C28F7E9140BA@ORSMSX104.amr.corp.intel.com>
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F7E9140BA@ORSMSX104.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Christoph Hellwig <hch@infradead.org>, Meelis Roos <mroos@linux.ee>, Christopher Lameter <cl@linux.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Mikulas Patocka <mpatocka@redhat.com>, James Bottomley <James.Bottomley@hansenpartnership.com>, "linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "Yu, Fenghua" <fenghua.yu@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

On Mon, Apr 29, 2019 at 04:58:09PM +0000, Luck, Tony wrote:
> > ia64 has a such a huge number of memory model choices.  Maybe we
> > need to cut it down to a small set that actually work.
> 
> SGI systems had extremely discontiguous memory (they used some high
> order physical address bits in the tens/hundreds of terabyte range for the
> node number ... so there would be a few GBytes of actual memory then
> a huge gap before the next node had a few more Gbytes).
> 
> I don't know of anyone still booting upstream on an SN2, so if we start doing
> serious hack and slash the chances are high that SN2 will be broken (if it isn't
> already).

When I wrote this, I thought of

!NUMA:  flat mem
NUMA:	sparsemem
SN2:	discontig

based on Meelis report.  But now that you mention it, I bet SN2 has
already died slow death from bitrot.  It is so different in places, and
it doesn't seem like anyone care - if people want room sized SGI
machines the Origin is much more sexy (hello Thomas!) :)

So maybe it it time to mark SN2 broken and see if anyone screams?

Without SN2 the whole machvec mess could basically go away - the
only real difference between the remaining machvecs is which iommu
if any we set up.
