From: Andrew Morton <akpm@linux-foundation.org>
Date: Mon, 04 Feb 2013 23:04:17 +0000
Subject: Re: [PATCH v6 08/15] memory-hotplug: Common APIs to support page tables hot-remove
Message-Id: <20130204150417.2b1256b1.akpm@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1357723959-5416-1-git-send-email-tangchen@cn.fujitsu.com>
	<1357723959-5416-9-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1357723959-5416-9-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: rientjes@google.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, wency@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, glommer@parallels.com, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org

On Wed, 9 Jan 2013 17:32:32 +0800
Tang Chen <tangchen@cn.fujitsu.com> wrote:

> +static void __meminit
> +remove_pagetable(unsigned long start, unsigned long end, bool direct)
> +{
> +	unsigned long next;
> +	pgd_t *pgd;
> +	pud_t *pud;
> +	bool pgd_changed = false;
> +
> +	for (; start < end; start = next) {
> +		pgd = pgd_offset_k(start);
> +		if (!pgd_present(*pgd))
> +			continue;
> +
> +		next = pgd_addr_end(start, end);
> +
> +		pud = (pud_t *)map_low_page((pud_t *)pgd_page_vaddr(*pgd));
> +		remove_pud_table(pud, start, next, direct);
> +		if (free_pud_table(pud, pgd))
> +			pgd_changed = true;
> +		unmap_low_page(pud);
> +	}
> +
> +	if (pgd_changed)
> +		sync_global_pgds(start, end - 1);
> +
> +	flush_tlb_all();
> +}

This generates a compiler warning saying that `next' may be used
uninitialised.

The warning is correct.  If we take that `continue' on the first pass
through the loop, the "start = next" will copy uninitialised data into
`start'.

Is this the correct fix?

--- a/arch/x86/mm/init_64.c~memory-hotplug-common-apis-to-support-page-tables-hot-remove-fix-fix-fix-fix-fix-fix-fix
+++ a/arch/x86/mm/init_64.c
@@ -993,12 +993,12 @@ remove_pagetable(unsigned long start, un
 	bool pgd_changed = false;
 
 	for (; start < end; start = next) {
+		next = pgd_addr_end(start, end);
+
 		pgd = pgd_offset_k(start);
 		if (!pgd_present(*pgd))
 			continue;
 
-		next = pgd_addr_end(start, end);
-
 		pud = (pud_t *)pgd_page_vaddr(*pgd);
 		remove_pud_table(pud, start, next, direct);
 		if (free_pud_table(pud, pgd))
_

