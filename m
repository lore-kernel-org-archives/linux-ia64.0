From: Andrew Morton <akpm@linux-foundation.org>
Date: Mon, 14 Oct 2019 19:17:19 +0000
Subject: Re: [PATCH v6 04/10] mm/memory_hotplug: Don't access uninitialized memmaps in shrink_zone_span()
Message-Id: <20191014121719.cb9b9efe51a7e9e985b38075@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191006085646.5768-1-david@redhat.com>
 <20191006085646.5768-5-david@redhat.com>
 <5a4573de-bd8a-6cd3-55d0-86d503a236fd@redhat.com>
In-Reply-To: <5a4573de-bd8a-6cd3-55d0-86d503a236fd@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Hildenbrand <david@redhat.com>
Cc: linux-s390@vger.kernel.org, Michal Hocko <mhocko@suse.com>, linux-ia64@vger.kernel.org, Pavel Tatashin <pasha.tatashin@soleen.com>, linux-sh@vger.kernel.org, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Williams <dan.j.williams@intel.com>, linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org, Oscar Salvador <osalvador@suse.de>

On Mon, 14 Oct 2019 11:32:13 +0200 David Hildenbrand <david@redhat.com> wrote:

> > Fixes: d0dc12e86b31 ("mm/memory_hotplug: optimize memory hotplug")
> 
> @Andrew, can you convert that to
> 
> Fixes: f1dd2cd13c4b ("mm, memory_hotplug: do not associate hotadded 
> memory to zones until online") # visible after d0dc12e86b319
> 
> and add
> 
> Cc: stable@vger.kernel.org # v4.13+

Done, thanks.
