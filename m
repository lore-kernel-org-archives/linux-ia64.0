From: Logan Gunthorpe <logang@deltatee.com>
Date: Wed, 08 Jan 2020 17:16:25 +0000
Subject: Re: [PATCH v2 2/8] mm/memory_hotplug: Rename mhp_restrictions to mhp_modifiers
Message-Id: <eef4ec73-8823-9f20-93ed-5c09f18c437a@deltatee.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200107205959.7575-1-logang@deltatee.com>
 <20200107205959.7575-3-logang@deltatee.com>
 <3e432695-e3a9-2aae-e9f5-1b6454886c06@redhat.com>
In-Reply-To: <3e432695-e3a9-2aae-e9f5-1b6454886c06@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Hildenbrand <david@redhat.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, platform-driver-x86@vger.kernel.org, linux-mm@kvack.org, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Eric Badger <ebadger@gigaio.com>, Peter Zijlstra <peterz@infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Thomas Gleixner <tglx@linutronix.de>, Will Deacon <will@kernel.org>, Christoph Hellwig <hch@lst.de>



On 2020-01-08 5:28 a.m., David Hildenbrand wrote:
> On 07.01.20 21:59, Logan Gunthorpe wrote:
>> The mhp_restrictions struct really doesn't specify anything resembling
>> a restriction anymore so rename it to be mhp_modifiers.
> 
> I wonder if something like "mhp_params" would be even better. It's
> essentially just a way to avoid changing call chains rough-out all archs
> whenever we want to add a new parameter.

Sure, that does sound a bit nicer to me. I can change it for v3.

Logan
