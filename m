From: Oscar Salvador <osalvador@suse.de>
Date: Mon, 10 Jun 2019 17:07:06 +0000
Subject: Re: [PATCH v3 02/11] s390x/mm: Fail when an altmap is used for arch_add_memory()
Message-Id: <20190610170705.GD5643@linux>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190527111152.16324-1-david@redhat.com>
 <20190527111152.16324-3-david@redhat.com>
In-Reply-To: <20190527111152.16324-3-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Hildenbrand <david@redhat.com>
Cc: Oscar Salvador <osalvador@suse.com>, linux-s390@vger.kernel.org, Michal Hocko <mhocko@suse.com>, linux-ia64@vger.kernel.org, Vasily Gorbik <gor@linux.ibm.com>, linux-sh@vger.kernel.org, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel@vger.kernel.org, Wei Yang <richard.weiyang@gmail.com>, linux-mm@kvack.org, Mike Rapoport <rppt@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Igor Mammedov <imammedo@redhat.com>, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org, Dan Williams <dan.j.williams@intel.com>, linux-arm-kernel@lists.infradead.org

On Mon, May 27, 2019 at 01:11:43PM +0200, David Hildenbrand wrote:
> ZONE_DEVICE is not yet supported, fail if an altmap is passed, so we
> don't forget arch_add_memory()/arch_remove_memory() when unlocking
> support.
> 
> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
> Cc: David Hildenbrand <david@redhat.com>
> Cc: Vasily Gorbik <gor@linux.ibm.com>
> Cc: Oscar Salvador <osalvador@suse.com>
> Suggested-by: Dan Williams <dan.j.williams@intel.com>
> Signed-off-by: David Hildenbrand <david@redhat.com>

Reviewed-by: Oscar Salvador <osalvador@suse.de>

-- 
Oscar Salvador
SUSE L3
