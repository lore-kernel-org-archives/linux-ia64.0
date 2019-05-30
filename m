From: Pavel Tatashin <pasha.tatashin@soleen.com>
Date: Thu, 30 May 2019 17:53:50 +0000
Subject: Re: [PATCH v3 01/11] mm/memory_hotplug: Simplify and fix check_hotplug_memory_range()
Message-Id: <CA+CK2bBW4vH+J6bam1dOxjSwFwvoOEok0VNO0n_JjyHxpkGj+A@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190527111152.16324-1-david@redhat.com>
 <20190527111152.16324-2-david@redhat.com>
In-Reply-To: <20190527111152.16324-2-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Hildenbrand <david@redhat.com>
Cc: linux-s390@vger.kernel.org, Michal Hocko <mhocko@suse.com>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Mathieu Malaterre <malat@debian.org>, LKML <linux-kernel@vger.kernel.org>, Wei Yang <richard.weiyang@gmail.com>, linux-mm <linux-mm@kvack.org>, Arun KS <arunks@codeaurora.org>, Qian Cai <cai@lca.pw>, Wei Yang <richardw.yang@linux.intel.com>, Igor Mammedov <imammedo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, Dan Williams <dan.j.williams@intel.com>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Oscar Salvador <osalvador@suse.de>

On Mon, May 27, 2019 at 7:12 AM David Hildenbrand <david@redhat.com> wrote:
>
> By converting start and size to page granularity, we actually ignore
> unaligned parts within a page instead of properly bailing out with an
> error.
>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Oscar Salvador <osalvador@suse.de>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: David Hildenbrand <david@redhat.com>
> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
> Cc: Qian Cai <cai@lca.pw>
> Cc: Wei Yang <richard.weiyang@gmail.com>
> Cc: Arun KS <arunks@codeaurora.org>
> Cc: Mathieu Malaterre <malat@debian.org>
> Reviewed-by: Dan Williams <dan.j.williams@intel.com>
> Reviewed-by: Wei Yang <richardw.yang@linux.intel.com>
> Signed-off-by: David Hildenbrand <david@redhat.com>

Reviewed-by: Pavel Tatashin <pasha.tatashin@soleen.com>
