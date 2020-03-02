From: Logan Gunthorpe <logang@deltatee.com>
Date: Mon, 02 Mar 2020 21:20:07 +0000
Subject: Re: [PATCH v3 7/7] mm/memremap: Set caching mode for PCI P2PDMA memory to WC
Message-Id: <6e2591ad-4605-aba4-c7b8-2345940e91b4@deltatee.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200221182503.28317-1-logang@deltatee.com>
 <20200221182503.28317-8-logang@deltatee.com>
 <CAPcyv4gNi3sesGnujShStoF8bi8kYg+MQkqhQRCT_1+wex5wbw@mail.gmail.com>
In-Reply-To: <CAPcyv4gNi3sesGnujShStoF8bi8kYg+MQkqhQRCT_1+wex5wbw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-ia64@vger.kernel.org, Linux-sh <linux-sh@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, Dave Hansen <dave.hansen@linux.intel.com>, platform-driver-x86@vger.kernel.org, Linux MM <linux-mm@kvack.org>, Will Deacon <will@kernel.org>, Christoph Hellwig <hch@lst.de>, linux-s390 <linux-s390@vger.kernel.org>, David Hildenbrand <david@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Ingo Molnar <mingo@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Michal Hocko <mhocko@kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Eric Badger <ebadger@gigaio.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>



On 2020-02-29 3:47 p.m., Dan Williams wrote:
> On Fri, Feb 21, 2020 at 10:25 AM Logan Gunthorpe <logang@deltatee.com> wrote:
>>
>> PCI BAR IO memory should never be mapped as WB, however prior to this
>> the PAT bits were set WB and it was typically overridden by MTRR
>> registers set by the firmware.
>>
>> Set PCI P2PDMA memory to be WC (writecombining) as the only current
>> user (the NVMe CMB) was originally mapped WC before the P2PDMA code
>> replaced the mapping with devm_memremap_pages().
> 
> Will the change to UC regress this existing use case?

I don't think so. They've been essentially mapped UC for a long time now
(since the P2PDMA patch set was merged) and nobody has complained.
