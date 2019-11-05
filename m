From: "tip-bot2 for Kees Cook" <tip-bot2@linutronix.de>
Date: Tue, 05 Nov 2019 09:27:26 +0000
Subject: [tip: x86/build] x86/mm: Report which part of kernel image is freed
Message-Id: <157294604642.29376.15246989052906644663.tip-bot2@tip-bot2>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191029211351.13243-28-keescook@chromium.org>
In-Reply-To: <20191029211351.13243-28-keescook@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-tip-commits@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, Borislav Petkov <bp@suse.de>, Andy Lutomirski <luto@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Dave Hansen <dave.hansen@linux.intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, linux-alpha@vger.kernel.org, linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, Michal Simek <monstr@monstr.eu>, Peter Zijlstra <peterz@infradead.org>, Rick Edgecombe <rick.p.edgecombe@intel.com>, Segher Boessenkool <segher@kernel.crashing.org>, Thomas Gleixner <tglx@linutronix.de>, Will Deacon <will@kernel.org>, x86-ml <x86@kernel.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, linux-kernel@vger.kernel.org

The following commit has been merged into the x86/build branch of tip:

Commit-ID:     5494c3a6a0b965906ffdcb620d94079ea4cb69ea
Gitweb:        https://git.kernel.org/tip/5494c3a6a0b965906ffdcb620d94079ea4cb69ea
Author:        Kees Cook <keescook@chromium.org>
AuthorDate:    Tue, 29 Oct 2019 14:13:49 -07:00
Committer:     Borislav Petkov <bp@suse.de>
CommitterDate: Mon, 04 Nov 2019 18:50:33 +01:00

x86/mm: Report which part of kernel image is freed

The memory freeing report wasn't very useful for figuring out which
parts of the kernel image were being freed. Add the details for clearer
reporting in dmesg.

Before:

  Freeing unused kernel image memory: 1348K
  Write protecting the kernel read-only data: 20480k
  Freeing unused kernel image memory: 2040K
  Freeing unused kernel image memory: 172K

After:

  Freeing unused kernel image (initmem) memory: 1348K
  Write protecting the kernel read-only data: 20480k
  Freeing unused kernel image (text/rodata gap) memory: 2040K
  Freeing unused kernel image (rodata/data gap) memory: 172K

Signed-off-by: Kees Cook <keescook@chromium.org>
Signed-off-by: Borislav Petkov <bp@suse.de>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: linux-alpha@vger.kernel.org
Cc: linux-arch@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-c6x-dev@linux-c6x.org
Cc: linux-ia64@vger.kernel.org
Cc: linuxppc-dev@lists.ozlabs.org
Cc: linux-s390@vger.kernel.org
Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: Michal Simek <monstr@monstr.eu>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Rick Edgecombe <rick.p.edgecombe@intel.com>
Cc: Segher Boessenkool <segher@kernel.crashing.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Will Deacon <will@kernel.org>
Cc: x86-ml <x86@kernel.org>
Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
Link: https://lkml.kernel.org/r/20191029211351.13243-28-keescook@chromium.org
---
 arch/x86/include/asm/processor.h | 2 +-
 arch/x86/mm/init.c               | 8 ++++----
 arch/x86/mm/init_64.c            | 6 ++++--
 3 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/arch/x86/include/asm/processor.h b/arch/x86/include/asm/processor.h
index 6e0a3b4..790f250 100644
--- a/arch/x86/include/asm/processor.h
+++ b/arch/x86/include/asm/processor.h
@@ -958,7 +958,7 @@ static inline uint32_t hypervisor_cpuid_base(const char *sig, uint32_t leaves)
 
 extern unsigned long arch_align_stack(unsigned long sp);
 void free_init_pages(const char *what, unsigned long begin, unsigned long end);
-extern void free_kernel_image_pages(void *begin, void *end);
+extern void free_kernel_image_pages(const char *what, void *begin, void *end);
 
 void default_idle(void);
 #ifdef	CONFIG_XEN
diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
index fd10d91..e7bb483 100644
--- a/arch/x86/mm/init.c
+++ b/arch/x86/mm/init.c
@@ -829,14 +829,13 @@ void free_init_pages(const char *what, unsigned long begin, unsigned long end)
  * used for the kernel image only.  free_init_pages() will do the
  * right thing for either kind of address.
  */
-void free_kernel_image_pages(void *begin, void *end)
+void free_kernel_image_pages(const char *what, void *begin, void *end)
 {
 	unsigned long begin_ul = (unsigned long)begin;
 	unsigned long end_ul = (unsigned long)end;
 	unsigned long len_pages = (end_ul - begin_ul) >> PAGE_SHIFT;
 
-
-	free_init_pages("unused kernel image", begin_ul, end_ul);
+	free_init_pages(what, begin_ul, end_ul);
 
 	/*
 	 * PTI maps some of the kernel into userspace.  For performance,
@@ -865,7 +864,8 @@ void __ref free_initmem(void)
 
 	mem_encrypt_free_decrypted_mem();
 
-	free_kernel_image_pages(&__init_begin, &__init_end);
+	free_kernel_image_pages("unused kernel image (initmem)",
+				&__init_begin, &__init_end);
 }
 
 #ifdef CONFIG_BLK_DEV_INITRD
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index e67ddca..dcb9bc9 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1334,8 +1334,10 @@ void mark_rodata_ro(void)
 	set_memory_ro(start, (end-start) >> PAGE_SHIFT);
 #endif
 
-	free_kernel_image_pages((void *)text_end, (void *)rodata_start);
-	free_kernel_image_pages((void *)rodata_end, (void *)_sdata);
+	free_kernel_image_pages("unused kernel image (text/rodata gap)",
+				(void *)text_end, (void *)rodata_start);
+	free_kernel_image_pages("unused kernel image (rodata/data gap)",
+				(void *)rodata_end, (void *)_sdata);
 
 	debug_checkwx();
 }
