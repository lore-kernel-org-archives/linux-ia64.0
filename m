From: Oscar Salvador <osalvador@suse.de>
Date: Mon, 24 Aug 2020 11:59:49 +0000
Subject: Re: [PATCH v2 09/10] mm: pass migratetype into memmap_init_zone() and move_pfn_range_to_zone()
Message-Id: <20200824115944.GA7491@linux>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200819175957.28465-1-david@redhat.com>
 <20200819175957.28465-10-david@redhat.com>
In-Reply-To: <20200819175957.28465-10-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Hildenbrand <david@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Wei Yang <richard.weiyang@linux.alibaba.com>, Baoquan He <bhe@redhat.com>, Pankaj Gupta <pankaj.gupta.linux@gmail.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Logan Gunthorpe <logang@deltatee.com>, Dan Williams <dan.j.williams@intel.com>, Mike Rapoport <rppt@kernel.org>, "Matthew Wilcox (Oracle)" <willy@infradead.org>, Michel Lespinasse <walken@google.com>, linux-ia64@vger.kernel.org

On Wed, Aug 19, 2020 at 07:59:56PM +0200, David Hildenbrand wrote:
> On the memory onlining path, we want to start with MIGRATE_ISOLATE, to
> un-isolate the pages after memory onlining is complete. Let's allow
> passing in the migratetype.
> 
> Acked-by: Michal Hocko <mhocko@suse.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Wei Yang <richard.weiyang@linux.alibaba.com>
> Cc: Baoquan He <bhe@redhat.com>
> Cc: Pankaj Gupta <pankaj.gupta.linux@gmail.com>
> Cc: Oscar Salvador <osalvador@suse.de>
> Cc: Tony Luck <tony.luck@intel.com>
> Cc: Fenghua Yu <fenghua.yu@intel.com>
> Cc: Logan Gunthorpe <logang@deltatee.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Mike Rapoport <rppt@kernel.org>
> Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>
> Cc: Michel Lespinasse <walken@google.com>
> Cc: linux-ia64@vger.kernel.org
> Signed-off-by: David Hildenbrand <david@redhat.com>

Reviewed-by: Oscar Salvador <osalvador@suse.de>

-- 
Oscar Salvador
SUSE L3
