From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Thu, 13 Apr 2006 16:36:05 +0000
Subject: RE: Make show_mem() skip holes in a pgdat.
Message-Id: <4t153d$lol5q@azsmga001.ch.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060413031519.GB2678@lnx-holt.americas.sgi.com>
In-Reply-To: <20060413031519.GB2678@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Robin Holt wrote on Wednesday, April 12, 2006 8:15 PM
> This patch modifies ia64's show_mem() to walk the vmem_map page tables and
> rapidly skip forward across regions where the page tables are missing.
> This prevents the pfn_valid() check from causing numerous unnecessary
> page faults.
> 
> Without this patch on a 512 node 512 cpu system where every node has four
> memory holes, the show_mem() call takes 1 hour 18 minutes.  With this
> patch, it takes less than 3 seconds.


If you are going to respin another rev, please consider the following.
no biggy, just some cosmetic stuff.

> +				pgd = pgd_offset_k(end_address);
> +				if (pgd_none(*pgd)) {
> +					end_address += PTRS_PER_PUD *
> +						       PTRS_PER_PMD *
> +						       PTRS_PER_PTE *
> +						       PAGE_SIZE;

end_address += PGDIR_SIZE;


> +				pud = pud_offset(pgd, end_address);
> +				if (pud_none(*pud)) {
> +					end_address += PTRS_PER_PMD *
> +						       PTRS_PER_PTE *
> +						       PAGE_SIZE;

end_address += PUD_SIZE;

> +
> +				pmd = pmd_offset(pud, end_address);
> +				if (pmd_none(*pmd)) {
> +					end_address += PTRS_PER_PTE *
> +						       PAGE_SIZE;

end_address += PMD_SIZE;
