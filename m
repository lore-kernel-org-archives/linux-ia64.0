From: David Hildenbrand <david@redhat.com>
Date: Mon, 24 Feb 2020 09:11:52 +0000
Subject: Re: [PATCH v3 2/7] mm/memory_hotplug: Rename mhp_restrictions to mhp_params
Message-Id: <e428521d-3509-5403-f8d8-c584a7d4d320@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200221182503.28317-1-logang@deltatee.com>
 <20200221182503.28317-3-logang@deltatee.com>
In-Reply-To: <20200221182503.28317-3-logang@deltatee.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Logan Gunthorpe <logang@deltatee.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, platform-driver-x86@vger.kernel.org, linux-mm@kvack.org, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Eric Badger <ebadger@gigaio.com>, Peter Zijlstra <peterz@infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Thomas Gleixner <tglx@linutronix.de>, Will Deacon <will@kernel.org>, Christoph Hellwig <hch@lst.de>

On 21.02.20 19:24, Logan Gunthorpe wrote:
> The mhp_restrictions struct really doesn't specify anything resembling
> a restriction anymore so rename it to be mhp_params as it is a list
> of extended parameters.
> 
> Signed-off-by: Logan Gunthorpe <logang@deltatee.com>

Reviewed-by: David Hildenbrand <david@redhat.com>


-- 
Thanks,

David / dhildenb
