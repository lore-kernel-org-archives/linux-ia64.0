From: Wei Yang <richardw.yang@linux.intel.com>
Date: Wed, 05 Feb 2020 11:48:32 +0000
Subject: Re: [PATCH v6 10/10] mm/memory_hotplug: Cleanup __remove_pages()
Message-Id: <20200205114832.GE24162@richard>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191006085646.5768-1-david@redhat.com>
 <20191006085646.5768-11-david@redhat.com>
In-Reply-To: <20191006085646.5768-11-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Hildenbrand <david@redhat.com>
Cc: linux-s390@vger.kernel.org, Michal Hocko <mhocko@suse.com>, linux-ia64@vger.kernel.org, Pavel Tatashin <pasha.tatashin@soleen.com>, linux-sh@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Wei Yang <richardw.yang@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, Dan Williams <dan.j.williams@intel.com>, linux-arm-kernel@lists.infradead.org, Oscar Salvador <osalvador@suse.de>

On Sun, Oct 06, 2019 at 10:56:46AM +0200, David Hildenbrand wrote:
>Let's drop the basically unused section stuff and simplify.
>
>Also, let's use a shorter variant to calculate the number of pages to
>the next section boundary.
>
>Cc: Andrew Morton <akpm@linux-foundation.org>
>Cc: Oscar Salvador <osalvador@suse.de>
>Cc: Michal Hocko <mhocko@suse.com>
>Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
>Cc: Dan Williams <dan.j.williams@intel.com>
>Cc: Wei Yang <richardw.yang@linux.intel.com>
>Signed-off-by: David Hildenbrand <david@redhat.com>

Finally understand the code.

Reviewed-by: Wei Yang <richardw.yang@linux.intel.com>

-- 
Wei Yang
Help you, Help me
