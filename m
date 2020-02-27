From: Logan Gunthorpe <logang@deltatee.com>
Date: Thu, 27 Feb 2020 17:54:40 +0000
Subject: Re: [PATCH v3 0/7] Allow setting caching mode in arch_add_memory() for P2PDMA
Message-Id: <7e573498-81c1-7f00-c1ff-ed16e12a5b96@deltatee.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200221182503.28317-1-logang@deltatee.com>
 <20200227171704.GK31668@ziepe.ca>
 <e8781f85-3fc7-b9ce-c751-606803cbdc77@deltatee.com>
 <20200227174311.GL31668@ziepe.ca>
In-Reply-To: <20200227174311.GL31668@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, Dave Hansen <dave.hansen@linux.intel.com>, platform-driver-x86@vger.kernel.org, linux-mm@kvack.org, Will Deacon <will@kernel.org>, Christoph Hellwig <hch@lst.de>, linux-s390@vger.kernel.org, David Hildenbrand <david@redhat.com>, Ingo Molnar <mingo@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dan Williams <dan.j.williams@intel.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Michal Hocko <mhocko@kernel.org>, linux-arm-kernel@lists.infradead.org, Eric Badger <ebadger@gigaio.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org



On 2020-02-27 10:43 a.m., Jason Gunthorpe wrote:
> Hm, AFAIK WC memory is not compatible with the spinlocks/mutexs/etc in
> Linux, so while it is true the memory has no side effects, there would
> be surprising concurrency risks if anything in the kernel tried to
> write to it.
> 
> Not compatible means the locks don't contain stores to WC memory the
> way you would expect. AFAIK on many CPUs extra barriers are required
> to keep WC stores ordered, the same way ARM already has extra barriers
> to keep UC stores ordered with locking..
> 
> The spinlocks are defined to contain UC stores though.
> 
> If there is no actual need today for WC I would suggest using UC as
> the default.

Ok, that sounds sensible. I'll do that in the next revision.

Thanks,

Logan
