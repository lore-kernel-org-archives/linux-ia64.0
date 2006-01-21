From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Sat, 21 Jan 2006 19:14:48 +0000
Subject: RE: ia64: allnoconfig build fails
Message-Id: <B05667366EE6204181EABE9C1B1C0EB5096C6658@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601210320.05771.len.brown@intel.com>
In-Reply-To: <200601210320.05771.len.brown@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Len Brown wrote on Saturday, January 21, 2006 12:20 AM
> mm/mempolicy.c: In function `huge_zonelist':
> mm/mempolicy.c:1045: error: `HPAGE_SHIFT' undeclared (first use in
this function)
> mm/mempolicy.c:1045: error: (Each undeclared identifier is reported
only once
> mm/mempolicy.c:1045: error: for each function it appears in.)
> make[1]: *** [mm/mempolicy.o] Error 1

Need to wrap huge_zonelist function with CONFIG_HUGETLBFS.


Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>


--- ./mm/mempolicy.c.orig	2006-01-21 11:00:30.000000000 -0800
+++ ./mm/mempolicy.c	2006-01-21 11:00:54.000000000 -0800
@@ -1034,6 +1034,7 @@ static inline unsigned interleave_nid(st
 		return interleave_nodes(pol);
 }
 
+#ifdef CONFIG_HUGETLBFS
 /* Return a zonelist suitable for a huge page allocation. */
 struct zonelist *huge_zonelist(struct vm_area_struct *vma, unsigned
long addr)
 {
@@ -1047,6 +1048,7 @@ struct zonelist *huge_zonelist(struct vm
 	}
 	return zonelist_policy(GFP_HIGHUSER, pol);
 }
+#endif
 
 /* Allocate a page in interleaved policy.
    Own path because it needs to do special accounting. */

