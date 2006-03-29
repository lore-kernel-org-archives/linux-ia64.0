From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Wed, 29 Mar 2006 17:01:44 +0000
Subject: Re: accessed/dirty bit handler tuning
Message-Id: <442ABD78.50104@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <44157CF1.5060902@bull.net>
In-Reply-To: <44157CF1.5060902@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Ken,

Can you please tell me why are the pud - pmd pointers are re-checked
in "vhpt_miss" ?

	ld8 r26=[r17]				// read *pmd again
#ifdef CONFIG_PGTABLE_4
	ld8 r19=[r28]				// read *pud again
#endif
...
	cmp.ne.or.andcm p6,p7=r26,r20		// did *pmd change
#ifdef CONFIG_PGTABLE_4
	cmp.ne.or.andcm p6,p7=r19,r29		// did *pud change
#endif

As far as I know, pud, pmd, pte pages can go away only via:

	free_pgtables()
		free_pgd_range()
			free_pud_range()
				free_pmd_range()
					free_pte_range()

If a 0xa000... stuff goes away => BUG.
For the user mode pages:

"free_pgtables()" is called only from:

- "exit_mmap()": we simply cannot have the chance to have a vhpt miss
- "unmap_region()" calls "unmap_vmas()" before "free_pgtables()":
   again, we cannot fault in that region

Have I missed something?

Thanks,

Zoltan
