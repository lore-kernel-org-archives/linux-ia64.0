From: Wei Yang <richard.weiyang@gmail.com>
Date: Thu, 09 May 2019 12:23:04 +0000
Subject: Re: [PATCH v2 1/8] mm/memory_hotplug: Simplify and fix check_hotplug_memory_range()
Message-Id: <20190509122304.haksywk3p2ks6gcg@master>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190507183804.5512-1-david@redhat.com>
 <20190507183804.5512-2-david@redhat.com>
In-Reply-To: <20190507183804.5512-2-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, akpm@linux-foundation.org, Dan Williams <dan.j.williams@intel.com>, Oscar Salvador <osalvador@suse.de>, Michal Hocko <mhocko@suse.com>, Pavel Tatashin <pasha.tatashin@soleen.com>, Qian Cai <cai@lca.pw>, Wei Yang <richard.weiyang@gmail.com>, Arun KS <arunks@codeaurora.org>, Mathieu Malaterre <malat@debian.org>

On Tue, May 07, 2019 at 08:37:57PM +0200, David Hildenbrand wrote:
>By converting start and size to page granularity, we actually ignore
>unaligned parts within a page instead of properly bailing out with an
>error.
>
>Cc: Andrew Morton <akpm@linux-foundation.org>
>Cc: Oscar Salvador <osalvador@suse.de>
>Cc: Michal Hocko <mhocko@suse.com>
>Cc: David Hildenbrand <david@redhat.com>
>Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
>Cc: Qian Cai <cai@lca.pw>
>Cc: Wei Yang <richard.weiyang@gmail.com>
>Cc: Arun KS <arunks@codeaurora.org>
>Cc: Mathieu Malaterre <malat@debian.org>
>Signed-off-by: David Hildenbrand <david@redhat.com>

Reviewed-by: Wei Yang <richardw.yang@linux.intel.com>


-- 
Wei Yang
Help you, Help me
