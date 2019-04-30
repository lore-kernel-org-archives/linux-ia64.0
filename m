From: Christopher Lameter <cl@linux.com>
Date: Tue, 30 Apr 2019 13:40:59 +0000
Subject: Re: DISCONTIGMEM is deprecated
Message-Id: <0100016a6e7a22d8-dcd24705-508f-4acc-8883-e5d61f4c0fa4-000000@email.amazonses.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190419094335.GJ18914@techsingularity.net> <20190419140521.GI7751@bombadil.infradead.org> <0100016a461809ed-be5bd8fc-9925-424d-9624-4a325a7a8860-000000@email.amazonses.com> <25cabb7c-9602-2e09-2fe0-cad3e54595fa@linux.ee> <20190428081353.GB30901@infradead.org>
 <3908561D78D1C84285E8C5FCA982C28F7E9140BA@ORSMSX104.amr.corp.intel.com> <20190429200957.GB27158@infradead.org>
In-Reply-To: <20190429200957.GB27158@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@infradead.org>
Cc: "Luck, Tony" <tony.luck@intel.com>, Meelis Roos <mroos@linux.ee>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Mikulas Patocka <mpatocka@redhat.com>, James Bottomley <James.Bottomley@hansenpartnership.com>, "linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "Yu, Fenghua" <fenghua.yu@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

On Mon, 29 Apr 2019, Christoph Hellwig wrote:

> So maybe it it time to mark SN2 broken and see if anyone screams?
>
> Without SN2 the whole machvec mess could basically go away - the
> only real difference between the remaining machvecs is which iommu
> if any we set up.

SPARSEMEM with VMEMMAP was developed to address these
issues and allow one mapping scheme across the different platforms.

You do not need DISCONTIGMEM support for SN2. And as far as I know (from a
decade ago ok....) the distributions were using VMEMMAP instead.

