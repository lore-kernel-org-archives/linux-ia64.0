From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 14 Jul 2006 17:11:53 +0000
Subject: RE: [PATCH] ia64: race flushing icache in COW path
Message-Id: <617E1C2C70743745A92448908E030B2A3CC204@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200607131700.k6DH0c5t001038@agluck-lia64.sc.intel.com>
In-Reply-To: <200607131700.k6DH0c5t001038@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Jason Baron <jbaron@redhat.com>, torvalds@osdl.org, akpm@osdl.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

@@ -1980,6 +1980,7 @@ static int do_swap_page(struct mm_struct
 	}
 
 	flush_icache_page(vma, page);
+	lazy_mmu_prot_update(pte);
 	set_pte_at(mm, address, page_table, pte);
 	page_add_anon_rmap(page, vma, address);
 

At first sight, this looks redundant ... but then I saw that
on ia64 "flush_icache_page()" is actually a no-op.  Perhaps
we can enter this in the next obfuscated C competition.

-Tony
