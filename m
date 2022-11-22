From: Nadav Amit <nadav.amit@gmail.com>
Date: Tue, 22 Nov 2022 19:53:27 +0000
Subject: [PATCH 1/3] kprobes: Mark descendents of core_kernel_text as notrace
Message-Id: <20221122195329.252654-2-namit@vmware.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20221122195329.252654-1-namit@vmware.com>
In-Reply-To: <20221122195329.252654-1-namit@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-um@lists.infradead.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Johannes Berg <johannes@sipsolutions.net>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Nadav Amit <namit@vmware.com>, Marcin Nowakowski <marcin.nowakowski@mips.com>

From: Nadav Amit <namit@vmware.com>

Commit c0d80ddab899 ("kernel/extable.c: mark core_kernel_text notrace")
disabled the tracing of core_kernel_text to avoid recursive calls. For
the same reasons, all the functions in the dynamic extents of
core_kernel_text should be marked as notrace.

Cc: Marcin Nowakowski <marcin.nowakowski@mips.com>
Signed-off-by: Nadav Amit <namit@vmware.com>
---
 arch/arm/kernel/process.c             | 2 +-
 arch/ia64/mm/init.c                   | 2 +-
 arch/x86/entry/vsyscall/vsyscall_64.c | 2 +-
 arch/x86/um/mem_32.c                  | 2 +-
 include/asm-generic/sections.h        | 6 +++---
 include/linux/kallsyms.h              | 6 +++---
 include/linux/mm.h                    | 2 +-
 7 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/arch/arm/kernel/process.c b/arch/arm/kernel/process.c
index a2b31d91a1b6..a32ca8fcab5a 100644
--- a/arch/arm/kernel/process.c
+++ b/arch/arm/kernel/process.c
@@ -331,7 +331,7 @@ int in_gate_area(struct mm_struct *mm, unsigned long addr)
 	return (addr >= gate_vma.vm_start) && (addr < gate_vma.vm_end);
 }
 
-int in_gate_area_no_mm(unsigned long addr)
+notrace int in_gate_area_no_mm(unsigned long addr)
 {
 	return in_gate_area(NULL, addr);
 }
diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index fc4e4217e87f..e3d63d3d3e59 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -284,7 +284,7 @@ struct vm_area_struct *get_gate_vma(struct mm_struct *mm)
 	return &gate_vma;
 }
 
-int in_gate_area_no_mm(unsigned long addr)
+notrace int in_gate_area_no_mm(unsigned long addr)
 {
 	if ((addr >= FIXADDR_USER_START) && (addr < FIXADDR_USER_END))
 		return 1;
diff --git a/arch/x86/entry/vsyscall/vsyscall_64.c b/arch/x86/entry/vsyscall/vsyscall_64.c
index 4af81df133ee..68ebad6abd2b 100644
--- a/arch/x86/entry/vsyscall/vsyscall_64.c
+++ b/arch/x86/entry/vsyscall/vsyscall_64.c
@@ -340,7 +340,7 @@ int in_gate_area(struct mm_struct *mm, unsigned long addr)
  * context. It is less reliable than using a task's mm and may give
  * false positives.
  */
-int in_gate_area_no_mm(unsigned long addr)
+notrace int in_gate_area_no_mm(unsigned long addr)
 {
 	return vsyscall_mode != NONE && (addr & PAGE_MASK) = VSYSCALL_ADDR;
 }
diff --git a/arch/x86/um/mem_32.c b/arch/x86/um/mem_32.c
index cafd01f730da..cfec8b00b136 100644
--- a/arch/x86/um/mem_32.c
+++ b/arch/x86/um/mem_32.c
@@ -28,7 +28,7 @@ struct vm_area_struct *get_gate_vma(struct mm_struct *mm)
 	return FIXADDR_USER_START ? &gate_vma : NULL;
 }
 
-int in_gate_area_no_mm(unsigned long addr)
+notrace int in_gate_area_no_mm(unsigned long addr)
 {
 	if (!FIXADDR_USER_START)
 		return 0;
diff --git a/include/asm-generic/sections.h b/include/asm-generic/sections.h
index db13bb620f52..d519965b67bf 100644
--- a/include/asm-generic/sections.h
+++ b/include/asm-generic/sections.h
@@ -188,7 +188,7 @@ static inline bool is_kernel_rodata(unsigned long addr)
  *
  * Returns: true if the address is located in .init.text, false otherwise.
  */
-static inline bool is_kernel_inittext(unsigned long addr)
+static notrace inline bool is_kernel_inittext(unsigned long addr)
 {
 	return addr >= (unsigned long)_sinittext &&
 	       addr < (unsigned long)_einittext;
@@ -203,7 +203,7 @@ static inline bool is_kernel_inittext(unsigned long addr)
  * Returns: true if the address is located in .text, false otherwise.
  * Note: an internal helper, only check the range of _stext to _etext.
  */
-static inline bool __is_kernel_text(unsigned long addr)
+static notrace inline bool __is_kernel_text(unsigned long addr)
 {
 	return addr >= (unsigned long)_stext &&
 	       addr < (unsigned long)_etext;
@@ -219,7 +219,7 @@ static inline bool __is_kernel_text(unsigned long addr)
  *       and range from __init_begin to __init_end, which can be outside
  *       of the _stext to _end range.
  */
-static inline bool __is_kernel(unsigned long addr)
+static notrace inline bool __is_kernel(unsigned long addr)
 {
 	return ((addr >= (unsigned long)_stext &&
 	         addr < (unsigned long)_end) ||
diff --git a/include/linux/kallsyms.h b/include/linux/kallsyms.h
index 649faac31ddb..7ee6a734b738 100644
--- a/include/linux/kallsyms.h
+++ b/include/linux/kallsyms.h
@@ -24,21 +24,21 @@
 struct cred;
 struct module;
 
-static inline int is_kernel_text(unsigned long addr)
+static notrace inline int is_kernel_text(unsigned long addr)
 {
 	if (__is_kernel_text(addr))
 		return 1;
 	return in_gate_area_no_mm(addr);
 }
 
-static inline int is_kernel(unsigned long addr)
+static notrace inline int is_kernel(unsigned long addr)
 {
 	if (__is_kernel(addr))
 		return 1;
 	return in_gate_area_no_mm(addr);
 }
 
-static inline int is_ksym_addr(unsigned long addr)
+static notrace inline int is_ksym_addr(unsigned long addr)
 {
 	if (IS_ENABLED(CONFIG_KALLSYMS_ALL))
 		return is_kernel(addr);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index bfac5a166cb8..36a938c10ede 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -3186,7 +3186,7 @@ static inline struct vm_area_struct *get_gate_vma(struct mm_struct *mm)
 {
 	return NULL;
 }
-static inline int in_gate_area_no_mm(unsigned long addr) { return 0; }
+static notrace inline int in_gate_area_no_mm(unsigned long addr) { return 0; }
 static inline int in_gate_area(struct mm_struct *mm, unsigned long addr)
 {
 	return 0;
-- 
2.25.1
