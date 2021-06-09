From: Heiko Carstens <hca@linux.ibm.com>
Date: Wed, 09 Jun 2021 05:51:02 +0000
Subject: Re: [PATCH v1 04/12] mm/memory_hotplug: remove nid parameter from arch_remove_memory()
Message-Id: <YMBWxiUGBjJCz1+q@osiris>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210607195430.48228-1-david@redhat.com>
 <20210607195430.48228-5-david@redhat.com>
In-Reply-To: <20210607195430.48228-5-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Hildenbrand <david@redhat.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Vitaly Kuznetsov <vkuznets@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>, Jason Wang <jasowang@redhat.com>, Marek Kedzierski <mkedzier@redhat.com>, Hui Zhu <teawater@gmail.com>, Pankaj Gupta <pankaj.gupta.linux@gmail.com>, Wei Yang <richard.weiyang@linux.alibaba.com>, Oscar Salvador <osalvador@suse.de>, Michal Hocko <mhocko@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Anshuman Khandual <anshuman.khandual@arm.com>, Dave Hansen <dave.hansen@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Mike Rapoport <rppt@kernel.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Pavel Tatashin <pasha.tatashin@soleen.com>, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Vasily Gorbik <gor@linux.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Ard Biesheuvel <ardb@kernel.org>, Nicholas Piggin <npiggin@gmail.com>, Baoquan He <bhe@redhat.com>, Laurent Dufour <ldufour@linux.ibm.com>, Sergei Trofimovich <slyfox@gentoo.org>, Kefeng Wang <wangkefeng.wang@huawei.com>, Michel Lespinasse <michel@lespinasse.org>, Christophe Leroy <christophe.leroy@c-s.fr>, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Thiago Jung Bauermann <bauerman@linux.ibm.com>, Joe Perches <joe@perches.com>, Pierre Morel <pmorel@linux.ibm.com>, Jia He <justin.he@arm.com>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org

On Mon, Jun 07, 2021 at 09:54:22PM +0200, David Hildenbrand wrote:
> The parameter is unused, let's remove it.
> 
> Signed-off-by: David Hildenbrand <david@redhat.com>
> ---
>  arch/arm64/mm/mmu.c            | 3 +--
>  arch/ia64/mm/init.c            | 3 +--
>  arch/powerpc/mm/mem.c          | 3 +--
>  arch/s390/mm/init.c            | 3 +--
>  arch/sh/mm/init.c              | 3 +--
>  arch/x86/mm/init_32.c          | 3 +--
>  arch/x86/mm/init_64.c          | 3 +--
>  include/linux/memory_hotplug.h | 3 +--
>  mm/memory_hotplug.c            | 4 ++--
>  mm/memremap.c                  | 5 +----
>  10 files changed, 11 insertions(+), 22 deletions(-)

For s390:
Acked-by: Heiko Carstens <hca@linux.ibm.com>
