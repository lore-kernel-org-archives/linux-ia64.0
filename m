From: Hugh Dickins <hughd@google.com>
Date: Fri, 30 Jul 2010 17:58:26 +0000
Subject: [PATCH] mm: fix ia64 crash when gcore reads gate area
Message-Id: <alpine.DEB.1.00.1007301053540.22681@tigran.mtv.corp.google.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20100720173512.GF26783@ldl.fc.hp.com> <20100721105136.9d4440de.kamezawa.hiroyu@jp.fujitsu.com> <20100721030629.GA9987@lackof.org> <alpine.DEB.1.00.1007202106420.12760@tigran.mtv.corp.google.com> <20100727071914.GB22945@lackof.org>
 <20100727180330.b6ecba7f.kamezawa.hiroyu@jp.fujitsu.com> <20100727144326.GC22945@lackof.org> <alpine.DEB.1.00.1007282031130.4207@tigran.mtv.corp.google.com> <20100729192216.GF20265@lackof.org> <alpine.DEB.1.00.1007291853450.4466@tigran.mtv.corp.google.com>
 <20100730043423.GH20265@lackof.org> <alpine.DEB.1.00.1007301049230.21157@tigran.mtv.corp.google.com>
In-Reply-To: <alpine.DEB.1.00.1007301049230.21157@tigran.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: dann frazier <dannf@dannf.org>, dann frazier <dannf@debian.org>, Andreas Barth <aba@not.so.argh.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Ralf Baechle <ralf@linux-mips.org>

Debian's ia64 autobuilders have been seeing kernel freeze or reboot
when running the gdb testsuite (Debian bug 588574): dannf bisected to
2.6.32 62eede62dafb4a6633eae7ffbeb34c60dba5e7b1 "mm: ZERO_PAGE without
PTE_SPECIAL"; and reproduced it with gdb's gcore on a simple target.

I'd missed updating the gate_vma handling in __get_user_pages(): that
happens to use vm_normal_page() (nowadays failing on the zero page),
yet reported success even when it failed to get a page - boom when
access_process_vm() tried to copy that to its intermediate buffer.

Fix this, resisting cleanups: in particular, leave it for now reporting
success when not asked to get any pages - very probably safe to change,
but let's not risk it without testing exposure.

Why did ia64 crash with 16kB pages, but succeed with 64kB pages?
Because setup_gate() pads each 64kB of its gate area with zero pages.

Reported-by: Andreas Barth <aba@not.so.argh.org>
Bisected-by: dann frazier <dannf@debian.org>
Signed-off-by: Hugh Dickins <hughd@google.com>
Tested-by: dann frazier <dannf@dannf.org>
Cc: stable@kernel.org
---
Please add into 2.6.32-stable, 2.6.33-stable, 2.6.34-stable.

 mm/memory.c |   16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

--- 2.6.35-rc6/mm/memory.c	2010-05-30 17:58:57.000000000 -0700
+++ linux/mm/memory.c	2010-07-29 17:57:29.000000000 -0700
@@ -1394,10 +1394,20 @@ int __get_user_pages(struct task_struct
 				return i ? : -EFAULT;
 			}
 			if (pages) {
-				struct page *page = vm_normal_page(gate_vma, start, *pte);
+				struct page *page;
+
+				page = vm_normal_page(gate_vma, start, *pte);
+				if (!page) {
+					if (!(gup_flags & FOLL_DUMP) &&
+					     is_zero_pfn(pte_pfn(*pte)))
+						page = pte_page(*pte);
+					else {
+						pte_unmap(pte);
+						return i ? : -EFAULT;
+					}
+				}
 				pages[i] = page;
-				if (page)
-					get_page(page);
+				get_page(page);
 			}
 			pte_unmap(pte);
 			if (vmas)
