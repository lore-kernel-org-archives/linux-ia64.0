From: "Zhang, Yanmin" <yanmin.zhang@intel.com>
Date: Sat, 19 Jun 2004 01:30:04 +0000
Subject: BUG: call to free_huge_page in arch_hugeltb_fault
Message-Id: <3AA03342E913FA4BA6D8BD0732BFC74B02409B0A@pdsmsx402.pd.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

In base kernel 2.6.7, there is bug in function arch_hugeltb_fault. The
call to free_huge_page is incorrect. I change it to page_cache_release.
On i386, it also has the same problem and I fix both in the below patch.
As a matter of fact, it seems all platforms which support hugetlb page
have such problem.

diff -Nraup a/arch/i386/mm/hugetlbpage.c b/arch/i386/mm/hugetlbpage.c
--- a/arch/i386/mm/hugetlbpage.c	2004-06-18 00:03:25.000000000
-0700
+++ b/arch/i386/mm/hugetlbpage.c	2004-06-18 07:26:01.230402486
-0700
@@ -268,7 +268,7 @@ int hugetlb_prefault(struct address_spac
 				unlock_page(page);
 			} else {
 				hugetlb_put_quota(mapping);
-				free_huge_page(page);
+				page_cache_release(page);
 				goto out;
 			}
 		}
diff -Nraup a/arch/ia64/mm/hugetlbpage.c b/arch/ia64/mm/hugetlbpage.c
--- a/arch/ia64/mm/hugetlbpage.c	2004-06-18 00:03:25.000000000
-0700
+++ b/arch/ia64/mm/hugetlbpage.c	2004-06-18 07:26:01.646418106
-0700
@@ -297,7 +297,7 @@ int hugetlb_prefault(struct address_spac
 				unlock_page(page);
 			} else {
 				hugetlb_put_quota(mapping);
-				free_huge_page(page);
+				page_cache_release(page);
 				goto out;
 			}
 		}

