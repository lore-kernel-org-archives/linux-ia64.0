From: Andi Kleen <andi@firstfloor.org>
Date: Mon, 08 Oct 2012 04:37:00 +0000
Subject: Re: [PATCH 8/10] memory-hotplug : remove page table of x86_64 architecture
Message-Id: <m2d30tvatv.fsf@firstfloor.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <506E43E0.70507@jp.fujitsu.com> <506E4799.30407@jp.fujitsu.com>
In-Reply-To: <506E4799.30407@jp.fujitsu.com> (Yasuaki Ishimatsu's message of
	"Fri, 5 Oct 2012 11:36:09 +0900")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, wency@cn.fujitsu.com

Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com> writes:
> +			}
> +
> +			/*
> +			 * We use 2M page, but we need to remove part of them,
> +			 * so split 2M page to 4K page.
> +			 */
> +			pte = alloc_low_page(&pte_phys);

What happens when the allocation fails?

alloc_low_page seems to be buggy there too, it would __pa a NULL 
pointer.

> +		if (pud_large(*pud)) {
> +			if ((addr & ~PUD_MASK) = 0 && next <= end) {
> +				set_pud(pud, __pud(0));
> +				pages++;
> +				continue;
> +			}
> +
> +			/*
> +			 * We use 1G page, but we need to remove part of them,
> +			 * so split 1G page to 2M page.
> +			 */
> +			pmd = alloc_low_page(&pmd_phys);

Same here

> +			__split_large_page((pte_t *)pud, addr, (pte_t *)pmd);
> +
> +			spin_lock(&init_mm.page_table_lock);
> +			pud_populate(&init_mm, pud, __va(pmd_phys));
> +			spin_unlock(&init_mm.page_table_lock);
> +		}
> +
> +		pmd = map_low_page(pmd_offset(pud, 0));
> +		phys_pmd_remove(pmd, addr, end);
> +		unmap_low_page(pmd);
> +		__flush_tlb_all();
> +	}
> +	__flush_tlb_all();

This doesn't flush the other CPUs doesn't it?

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only
