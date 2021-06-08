From: Michael Ellerman <mpe@ellerman.id.au>
Date: Tue, 08 Jun 2021 10:50:21 +0000
Subject: Re: [PATCH v1 04/12] mm/memory_hotplug: remove nid parameter from arch_remove_memory()
Message-Id: <871r9cfx5e.fsf@mpe.ellerman.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210607195430.48228-1-david@redhat.com>
 <20210607195430.48228-5-david@redhat.com>
In-Reply-To: <20210607195430.48228-5-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Hildenbrand <david@redhat.com>, linux-kernel@vger.kernel.org
Cc: David Hildenbrand <david@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Vitaly Kuznetsov <vkuznets@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>, Jason Wang <jasowang@redhat.com>, Marek Kedzierski <mkedzier@redhat.com>, Hui Zhu <teawater@gmail.com>, Pankaj Gupta <pankaj.gupta.linux@gmail.com>, Wei Yang <richard.weiyang@linux.alibaba.com>, Oscar Salvador <osalvador@suse.de>, Michal Hocko <mhocko@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Anshuman Khandual <anshuman.khandual@arm.com>, Dave Hansen <dave.hansen@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Mike Rapoport <rppt@kernel.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Pavel Tatashin <pasha.tatashin@soleen.com>, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Heiko Carstens <hca@linux.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Ard Biesheuvel <ardb@kernel.org>, Nicholas Piggin <npiggin@gmail.com>, Baoquan He <bhe@redhat.com>, Laurent Dufour <ldufour@linux.ibm.com>, Sergei Trofimovich <slyfox@gentoo.org>, Kefeng Wang <wangkefeng.wang@huawei.com>, Michel Lespinasse <michel@lespinasse.org>, Christophe Leroy <christophe.leroy@c-s.fr>, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Thiago Jung Bauermann <bauerman@linux.ibm.com>, Joe Perches <joe@perches.com>, Pierre Morel <pmorel@linux.ibm.com>, Jia He <justin.he@arm.com>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org

David Hildenbrand <david@redhat.com> writes:

> The parameter is unused, let's remove it.
>
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Will Deacon <will@kernel.org>
> Cc: Michael Ellerman <mpe@ellerman.id.au>
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: Paul Mackerras <paulus@samba.org>
> Cc: Heiko Carstens <hca@linux.ibm.com>
> Cc: Vasily Gorbik <gor@linux.ibm.com>
> Cc: Christian Borntraeger <borntraeger@de.ibm.com>
> Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
> Cc: Rich Felker <dalias@libc.org>
> Cc: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: Andy Lutomirski <luto@kernel.org>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: Borislav Petkov <bp@alien8.de>
> Cc: x86@kernel.org
> Cc: "H. Peter Anvin" <hpa@zytor.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Anshuman Khandual <anshuman.khandual@arm.com>
> Cc: Ard Biesheuvel <ardb@kernel.org>
> Cc: Mike Rapoport <rppt@kernel.org>
> Cc: Nicholas Piggin <npiggin@gmail.com>
> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
> Cc: Baoquan He <bhe@redhat.com>
> Cc: Laurent Dufour <ldufour@linux.ibm.com>
> Cc: Sergei Trofimovich <slyfox@gentoo.org>
> Cc: Kefeng Wang <wangkefeng.wang@huawei.com>
> Cc: Michel Lespinasse <michel@lespinasse.org>
> Cc: Christophe Leroy <christophe.leroy@c-s.fr>
> Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
> Cc: Thiago Jung Bauermann <bauerman@linux.ibm.com>
> Cc: Joe Perches <joe@perches.com>
> Cc: Pierre Morel <pmorel@linux.ibm.com>
> Cc: Jia He <justin.he@arm.com>
> Cc: linux-arm-kernel@lists.infradead.org
> Cc: linux-ia64@vger.kernel.org
> Cc: linuxppc-dev@lists.ozlabs.org
> Cc: linux-s390@vger.kernel.org
> Cc: linux-sh@vger.kernel.org
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
>
...
> diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
> index 043bbeaf407c..fc5c36189c26 100644
> --- a/arch/powerpc/mm/mem.c
> +++ b/arch/powerpc/mm/mem.c
> @@ -115,8 +115,7 @@ int __ref arch_add_memory(int nid, u64 start, u64 size,
>  	return rc;
>  }
>  
> -void __ref arch_remove_memory(int nid, u64 start, u64 size,
> -			      struct vmem_altmap *altmap)
> +void __ref arch_remove_memory(u64 start, u64 size, struct vmem_altmap *altmap)
>  {
>  	unsigned long start_pfn = start >> PAGE_SHIFT;
>  	unsigned long nr_pages = size >> PAGE_SHIFT;

Acked-by: Michael Ellerman <mpe@ellerman.id.au> (powerpc)

cheers
