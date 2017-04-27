From: Xunlei Pang <xlpang@redhat.com>
Date: Thu, 27 Apr 2017 08:17:01 +0000
Subject: [PATCH v5 3/3] kdump: Protect vmcoreinfo data under the crash memory
Message-Id: <1493281021-20737-3-git-send-email-xlpang@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1493281021-20737-1-git-send-email-xlpang@redhat.com>
In-Reply-To: <1493281021-20737-1-git-send-email-xlpang@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, kexec@lists.infradead.org
Cc: akpm@linux-foundation.org, Eric Biederman <ebiederm@xmission.com>, Dave Young <dyoung@redhat.com>, Baoquan He <bhe@redhat.com>, Petr Tesarik <ptesarik@suse.cz>, Hari Bathini <hbathini@linux.vnet.ibm.com>, Michael Holzheu <holzheu@linux.vnet.ibm.com>, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-ia64@vger.kernel.org, Xunlei Pang <xlpang@redhat.com>

Currently vmcoreinfo data is updated at boot time subsys_initcall(),
it has the risk of being modified by some wrong code during system
is running.

As a result, vmcore dumped may contain the wrong vmcoreinfo. Later on,
when using "crash", "makedumpfile", etc utility to parse this vmcore,
we probably will get "Segmentation fault" or other unexpected errors.

E.g. 1) wrong code overwrites vmcoreinfo_data; 2) further crashes the
system; 3) trigger kdump, then we obviously will fail to recognize the
crash context correctly due to the corrupted vmcoreinfo.

Now except for vmcoreinfo, all the crash data is well protected(including
the cpu note which is fully updated in the crash path, thus its correctness
is guaranteed). Given that vmcoreinfo data is a large chunk prepared for
kdump, we better protect it as well.

To solve this, we relocate and copy vmcoreinfo_data to the crash memory
when kdump is loading via kexec syscalls. Because the whole crash memory
will be protected by existing arch_kexec_protect_crashkres() mechanism,
we naturally protect vmcoreinfo_data from write(even read) access under
kernel direct mapping after kdump is loaded.

Since kdump is usually loaded at the very early stage after boot, we can
trust the correctness of the vmcoreinfo data copied.

On the other hand, we still need to operate the vmcoreinfo safe copy when
crash happens to generate vmcoreinfo_note again, we rely on vmap() to map
out a new kernel virtual address and update to use this new one instead in
the following crash_save_vmcoreinfo().

BTW, we do not touch vmcoreinfo_note, because it will be fully updated
using the protected vmcoreinfo_data after crash which is surely correct
just like the cpu crash note.

Tested-by: Michael Holzheu <holzheu@linux.vnet.ibm.com>
Signed-off-by: Xunlei Pang <xlpang@redhat.com>
---
v4->v5:
- Moved vunmap(image->vmcoreinfo_data_copy) above to avoid confusion.
- No functional change.

v3->v4:
-Rebased on the latest linux-next
-Copy vmcoreinfo after machine_kexec_prepare()

 include/linux/crash_core.h |  2 +-
 include/linux/kexec.h      |  2 ++
 kernel/crash_core.c        | 17 ++++++++++++++++-
 kernel/kexec.c             |  8 ++++++++
 kernel/kexec_core.c        | 39 +++++++++++++++++++++++++++++++++++++++
 kernel/kexec_file.c        |  8 ++++++++
 6 files changed, 74 insertions(+), 2 deletions(-)

diff --git a/include/linux/crash_core.h b/include/linux/crash_core.h
index 4555c09..e9de6b4 100644
--- a/include/linux/crash_core.h
+++ b/include/linux/crash_core.h
@@ -23,6 +23,7 @@
 
 typedef u32 note_buf_t[CRASH_CORE_NOTE_BYTES/4];
 
+void crash_update_vmcoreinfo_safecopy(void *ptr);
 void crash_save_vmcoreinfo(void);
 void arch_crash_save_vmcoreinfo(void);
 __printf(1, 2)
@@ -54,7 +55,6 @@
 	vmcoreinfo_append_str("PHYS_BASE=%lx\n", (unsigned long)value)
 
 extern u32 *vmcoreinfo_note;
-extern size_t vmcoreinfo_size;
 
 Elf_Word *append_elf_note(Elf_Word *buf, char *name, unsigned int type,
 			  void *data, size_t data_len);
diff --git a/include/linux/kexec.h b/include/linux/kexec.h
index c9481eb..3ea8275 100644
--- a/include/linux/kexec.h
+++ b/include/linux/kexec.h
@@ -181,6 +181,7 @@ struct kimage {
 	unsigned long start;
 	struct page *control_code_page;
 	struct page *swap_page;
+	void *vmcoreinfo_data_copy; /* locates in the crash memory */
 
 	unsigned long nr_segments;
 	struct kexec_segment segment[KEXEC_SEGMENT_MAX];
@@ -250,6 +251,7 @@ extern void *kexec_purgatory_get_symbol_addr(struct kimage *image,
 int kexec_should_crash(struct task_struct *);
 int kexec_crash_loaded(void);
 void crash_save_cpu(struct pt_regs *regs, int cpu);
+extern int kimage_crash_copy_vmcoreinfo(struct kimage *image);
 
 extern struct kimage *kexec_image;
 extern struct kimage *kexec_crash_image;
diff --git a/kernel/crash_core.c b/kernel/crash_core.c
index c2fd0d2..4a4a4ba 100644
--- a/kernel/crash_core.c
+++ b/kernel/crash_core.c
@@ -15,9 +15,12 @@
 
 /* vmcoreinfo stuff */
 static unsigned char *vmcoreinfo_data;
-size_t vmcoreinfo_size;
+static size_t vmcoreinfo_size;
 u32 *vmcoreinfo_note;
 
+/* trusted vmcoreinfo, e.g. we can make a copy in the crash memory */
+static unsigned char *vmcoreinfo_data_safecopy;
+
 /*
  * parsing the "crashkernel" commandline
  *
@@ -323,11 +326,23 @@ static void update_vmcoreinfo_note(void)
 	final_note(buf);
 }
 
+void crash_update_vmcoreinfo_safecopy(void *ptr)
+{
+	if (ptr)
+		memcpy(ptr, vmcoreinfo_data, vmcoreinfo_size);
+
+	vmcoreinfo_data_safecopy = ptr;
+}
+
 void crash_save_vmcoreinfo(void)
 {
 	if (!vmcoreinfo_note)
 		return;
 
+	/* Use the safe copy to generate vmcoreinfo note if have */
+	if (vmcoreinfo_data_safecopy)
+		vmcoreinfo_data = vmcoreinfo_data_safecopy;
+
 	vmcoreinfo_append_str("CRASHTIME=%ld\n", get_seconds());
 	update_vmcoreinfo_note();
 }
diff --git a/kernel/kexec.c b/kernel/kexec.c
index 980936a..e62ec4d 100644
--- a/kernel/kexec.c
+++ b/kernel/kexec.c
@@ -144,6 +144,14 @@ static int do_kexec_load(unsigned long entry, unsigned long nr_segments,
 	if (ret)
 		goto out;
 
+	/*
+	 * Some architecture(like S390) may touch the crash memory before
+	 * machine_kexec_prepare(), we must copy vmcoreinfo data after it.
+	 */
+	ret = kimage_crash_copy_vmcoreinfo(image);
+	if (ret)
+		goto out;
+
 	for (i = 0; i < nr_segments; i++) {
 		ret = kimage_load_segment(image, &image->segment[i]);
 		if (ret)
diff --git a/kernel/kexec_core.c b/kernel/kexec_core.c
index ae1a3ba..a5f0d9b 100644
--- a/kernel/kexec_core.c
+++ b/kernel/kexec_core.c
@@ -481,6 +481,40 @@ struct page *kimage_alloc_control_pages(struct kimage *image,
 	return pages;
 }
 
+int kimage_crash_copy_vmcoreinfo(struct kimage *image)
+{
+	struct page *vmcoreinfo_page;
+	void *safecopy;
+
+	if (image->type != KEXEC_TYPE_CRASH)
+		return 0;
+
+	/*
+	 * For kdump, allocate one vmcoreinfo safe copy from the
+	 * crash memory. as we have arch_kexec_protect_crashkres()
+	 * after kexec syscall, we naturally protect it from write
+	 * (even read) access under kernel direct mapping. But on
+	 * the other hand, we still need to operate it when crash
+	 * happens to generate vmcoreinfo note, hereby we rely on
+	 * vmap for this purpose.
+	 */
+	vmcoreinfo_page = kimage_alloc_control_pages(image, 0);
+	if (!vmcoreinfo_page) {
+		pr_warn("Could not allocate vmcoreinfo buffer\n");
+		return -ENOMEM;
+	}
+	safecopy = vmap(&vmcoreinfo_page, 1, VM_MAP, PAGE_KERNEL);
+	if (!safecopy) {
+		pr_warn("Could not vmap vmcoreinfo buffer\n");
+		return -ENOMEM;
+	}
+
+	image->vmcoreinfo_data_copy = safecopy;
+	crash_update_vmcoreinfo_safecopy(safecopy);
+
+	return 0;
+}
+
 static int kimage_add_entry(struct kimage *image, kimage_entry_t entry)
 {
 	if (*image->entry != 0)
@@ -568,6 +602,11 @@ void kimage_free(struct kimage *image)
 	if (!image)
 		return;
 
+	if (image->vmcoreinfo_data_copy) {
+		crash_update_vmcoreinfo_safecopy(NULL);
+		vunmap(image->vmcoreinfo_data_copy);
+	}
+
 	kimage_free_extra_pages(image);
 	for_each_kimage_entry(image, ptr, entry) {
 		if (entry & IND_INDIRECTION) {
diff --git a/kernel/kexec_file.c b/kernel/kexec_file.c
index b118735..f78f719 100644
--- a/kernel/kexec_file.c
+++ b/kernel/kexec_file.c
@@ -304,6 +304,14 @@ void kimage_file_post_load_cleanup(struct kimage *image)
 	if (ret)
 		goto out;
 
+	/*
+	 * Some architecture(like S390) may touch the crash memory before
+	 * machine_kexec_prepare(), we must copy vmcoreinfo data after it.
+	 */
+	ret = kimage_crash_copy_vmcoreinfo(image);
+	if (ret)
+		goto out;
+
 	ret = kexec_calculate_store_digests(image);
 	if (ret)
 		goto out;
-- 
1.8.3.1

