From: Greg KH <gregkh@suse.de>
Date: Thu, 17 Dec 2009 03:57:08 +0000
Subject: [131/151] vmalloc: conditionalize build of pcpu_get_vm_areas()
Message-Id: <20091217035659.980303721@mini.kroah.org>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <20091217040208.GA26571@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, stable@kernel.org
Cc: stable-review@kernel.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, alan@lxorguk.ukuu.org.uk, tony.luck@intel.com, linux-ia64@vger.kernel.org, Jan Beulich <JBeulich@novell.com>, linux-mm@kvack.org, Geert Uytterhoeven <geert@linux-m68k.org>, Tejun Heo <tj@kernel.org>

2.6.32-stable review patch.  If anyone has any objections, please let us know.

------------------

From: Tejun Heo <teheo@novell.com>

No matching upstream commit as it was resolved differently there.


pcpu_get_vm_areas() is used only when dynamic percpu allocator is used
by the architecture.  In 2.6.32, ia64 doesn't use dynamic percpu
allocator and has a macro which makes pcpu_get_vm_areas() buggy via
local/global variable aliasing and triggers compile warning.

The problem is fixed in upstream and ia64 uses dynamic percpu
allocators, so the only left issue is inclusion of unnecessary code
and compile warning on ia64 on 2.6.32.

Don't build pcpu_get_vm_areas() if legacy percpu allocator is in use.

Signed-off-by: Tejun Heo <tj@kernel.org>
Reported-by: Jan Beulich <JBeulich@novell.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 include/linux/vmalloc.h |    2 ++
 mm/vmalloc.c            |    2 ++
 2 files changed, 4 insertions(+)

--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -115,9 +115,11 @@ extern rwlock_t vmlist_lock;
 extern struct vm_struct *vmlist;
 extern __init void vm_area_register_early(struct vm_struct *vm, size_t align);
 
+#ifndef CONFIG_HAVE_LEGACY_PER_CPU_AREA
 struct vm_struct **pcpu_get_vm_areas(const unsigned long *offsets,
 				     const size_t *sizes, int nr_vms,
 				     size_t align, gfp_t gfp_mask);
+#endif
 
 void pcpu_free_vm_areas(struct vm_struct **vms, int nr_vms);
 
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1993,6 +1993,7 @@ void free_vm_area(struct vm_struct *area
 }
 EXPORT_SYMBOL_GPL(free_vm_area);
 
+#ifndef CONFIG_HAVE_LEGACY_PER_CPU_AREA
 static struct vmap_area *node_to_va(struct rb_node *n)
 {
 	return n ? rb_entry(n, struct vmap_area, rb_node) : NULL;
@@ -2257,6 +2258,7 @@ err_free:
 	kfree(vms);
 	return NULL;
 }
+#endif
 
 /**
  * pcpu_free_vm_areas - free vmalloc areas for percpu allocator


