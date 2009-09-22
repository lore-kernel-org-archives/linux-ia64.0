From: Tejun Heo <tj@kernel.org>
Date: Tue, 22 Sep 2009 07:40:11 +0000
Subject: [PATCH 1/4] vmalloc: rename local variables vmalloc_start and vmalloc_end
Message-Id: <1253605214-23210-2-git-send-email-tj@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1253605214-23210-1-git-send-email-tj@kernel.org>
In-Reply-To: <1253605214-23210-1-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nick Piggin <npiggin@suse.de>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64 <linux-ia64@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, Rusty Russell <rusty@rustcorp.com.au>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Tejun Heo <tj@kernel.org>, Nick Piggin <npiggin@suse.de>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64 <linux-ia64@vger.kernel.org>

ia64 defines global vmalloc_end and VMALLOC_END as an alias to it, so
using local variable named vmalloc_end and initializing it from
VMALLOC_END makes it a bogus initialization like the following.

  const unsigned long vmalloc_end = vmalloc_end & ~(align - 1);

Rename local variables vmalloc_start and vmalloc_end to vm_start and
vm_end to avoid the collision.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Nick Piggin <npiggin@suse.de>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64 <linux-ia64@vger.kernel.org>
---
 mm/vmalloc.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 204b824..416e7fe 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1901,13 +1901,13 @@ static unsigned long pvm_determine_end(struct vmap_area **pnext,
 				       struct vmap_area **pprev,
 				       unsigned long align)
 {
-	const unsigned long vmalloc_end = VMALLOC_END & ~(align - 1);
+	const unsigned long vm_end = VMALLOC_END & ~(align - 1);
 	unsigned long addr;
 
 	if (*pnext)
-		addr = min((*pnext)->va_start & ~(align - 1), vmalloc_end);
+		addr = min((*pnext)->va_start & ~(align - 1), vm_end);
 	else
-		addr = vmalloc_end;
+		addr = vm_end;
 
 	while (*pprev && (*pprev)->va_end > addr) {
 		*pnext = *pprev;
@@ -1946,8 +1946,8 @@ struct vm_struct **pcpu_get_vm_areas(const unsigned long *offsets,
 				     const size_t *sizes, int nr_vms,
 				     size_t align, gfp_t gfp_mask)
 {
-	const unsigned long vmalloc_start = ALIGN(VMALLOC_START, align);
-	const unsigned long vmalloc_end = VMALLOC_END & ~(align - 1);
+	const unsigned long vm_start = ALIGN(VMALLOC_START, align);
+	const unsigned long vm_end = VMALLOC_END & ~(align - 1);
 	struct vmap_area **vas, *prev, *next;
 	struct vm_struct **vms;
 	int area, area2, last_area, term_area;
@@ -1983,7 +1983,7 @@ struct vm_struct **pcpu_get_vm_areas(const unsigned long *offsets,
 	}
 	last_end = offsets[last_area] + sizes[last_area];
 
-	if (vmalloc_end - vmalloc_start < last_end) {
+	if (vm_end - vm_start < last_end) {
 		WARN_ON(true);
 		return NULL;
 	}
@@ -2008,7 +2008,7 @@ retry:
 	end = start + sizes[area];
 
 	if (!pvm_find_next_prev(vmap_area_pcpu_hole, &next, &prev)) {
-		base = vmalloc_end - last_end;
+		base = vm_end - last_end;
 		goto found;
 	}
 	base = pvm_determine_end(&next, &prev, align) - end;
@@ -2021,7 +2021,7 @@ retry:
 		 * base might have underflowed, add last_end before
 		 * comparing.
 		 */
-		if (base + last_end < vmalloc_start + last_end) {
+		if (base + last_end < vm_start + last_end) {
 			spin_unlock(&vmap_area_lock);
 			if (!purged) {
 				purge_vmap_area_lazy();
-- 
1.6.4.2

