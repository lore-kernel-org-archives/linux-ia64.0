From: Michal Hocko <mhocko@suse.com>
Date: Wed, 19 Aug 2020 13:08:35 +0000
Subject: Re: [PATCH v1 10/11] mm: pass migratetype into memmap_init_zone() and move_pfn_range_to_zone()
Message-Id: <20200819130835.GO5422@dhcp22.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200819101157.12723-1-david@redhat.com>
 <20200819101157.12723-11-david@redhat.com>
In-Reply-To: <20200819101157.12723-11-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Hildenbrand <david@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Wei Yang <richard.weiyang@linux.alibaba.com>, Baoquan He <bhe@redhat.com>, Pankaj Gupta <pankaj.gupta.linux@gmail.com>, Oscar Salvador <osalvador@suse.de>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Logan Gunthorpe <logang@deltatee.com>, Dan Williams <dan.j.williams@intel.com>, Mike Rapoport <rppt@kernel.org>, "Matthew Wilcox (Oracle)" <willy@infradead.org>, Michel Lespinasse <walken@google.com>, linux-ia64@vger.kernel.org

On Wed 19-08-20 12:11:56, David Hildenbrand wrote:
> On the memory hotplug path, we want to start with MIGRATE_ISOLATE, to
> un-isolate the pages after memory onlining is complete. Let's allow
> passing in the migratetype.
> 
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

Acked-by: Michal Hocko <mhocko@suse.com>
-- 
Michal Hocko
SUSE Labs
