From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 29 Apr 2019 16:58:09 +0000
Subject: RE: DISCONTIGMEM is deprecated
Message-Id: <3908561D78D1C84285E8C5FCA982C28F7E9140BA@ORSMSX104.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190419094335.GJ18914@techsingularity.net>
 <20190419140521.GI7751@bombadil.infradead.org>
 <0100016a461809ed-be5bd8fc-9925-424d-9624-4a325a7a8860-000000@email.amazonses.com>
 <25cabb7c-9602-2e09-2fe0-cad3e54595fa@linux.ee>
 <20190428081353.GB30901@infradead.org>
In-Reply-To: <20190428081353.GB30901@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@infradead.org>, Meelis Roos <mroos@linux.ee>
Cc: Christopher Lameter <cl@linux.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Mikulas Patocka <mpatocka@redhat.com>, James Bottomley <James.Bottomley@hansenpartnership.com>, "linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "Yu, Fenghua" <fenghua.yu@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

> ia64 has a such a huge number of memory model choices.  Maybe we
> need to cut it down to a small set that actually work.

SGI systems had extremely discontiguous memory (they used some high
order physical address bits in the tens/hundreds of terabyte range for the
node number ... so there would be a few GBytes of actual memory then
a huge gap before the next node had a few more Gbytes).

I don't know of anyone still booting upstream on an SN2, so if we start doing
serious hack and slash the chances are high that SN2 will be broken (if it isn't
already).

-Tony
