From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 24 Aug 2010 22:03:02 +0000
Subject: [PATCH] hide guard page for stacks that grow upwards
Message-Id: <4c74419664798b8c9@agluck-desktop.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-parisc@vger.kernel.org, linux-ia64@vger.kernel.org

pa-risc and ia64 have stacks that grow upwards. Don't
show the guard page on upward growing vma in /proc/$$/maps

Signed-off-by: Tony Luck <tony.luck@intel.com>

---

This looks useful too ... but I can't see where the code is that
made vm_start be PAGE_SIZE lower to begin with. I'd expect to have
to make a matching change to make vm_end PAGE_SIZE higher for the
VM_GROWSUP areas.

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 439fc1f..ef262f6 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -210,7 +210,7 @@ static void show_map_vma(struct seq_file *m, struct vm_area_struct *vma)
 	int flags = vma->vm_flags;
 	unsigned long ino = 0;
 	unsigned long long pgoff = 0;
-	unsigned long start;
+	unsigned long start, end;
 	dev_t dev = 0;
 	int len;
 
@@ -223,12 +223,15 @@ static void show_map_vma(struct seq_file *m, struct vm_area_struct *vma)
 
 	/* We don't show the stack guard page in /proc/maps */
 	start = vma->vm_start;
+	end = vma->vm_end;
 	if (vma->vm_flags & VM_GROWSDOWN)
 		start += PAGE_SIZE;
+	if (vma->vm_flags & VM_GROWSUP)
+		end -= PAGE_SIZE;
 
 	seq_printf(m, "%08lx-%08lx %c%c%c%c %08llx %02x:%02x %lu %n",
 			start,
-			vma->vm_end,
+			end,
 			flags & VM_READ ? 'r' : '-',
 			flags & VM_WRITE ? 'w' : '-',
 			flags & VM_EXEC ? 'x' : '-',
