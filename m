From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 10 Jul 2004 04:39:00 +0000
Subject: fix memory corruption/crash for physical-mode EFI calls
Message-Id: <16623.29412.381259.793452@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jesse,

I think you'll want to try out the patch below.  If my guess is
correct and the SGI firmware doesn't support switching into virtual
mode, then this may fix the boot-problem you are seeing on SN2.

We found this problem after I noticed that the Ski simulator always
wanted to fsck its filesystem.  That turned out to be because the
phys_get_time() in efi.c used __pa() to convert the address of a
stack-variable to a physical address.  Only problem was that the
stack-variable was on the init-task's stack, so it was in region 5.
Effectively, this ended up writing the correct time to a bogus memory
address.  In the simulator, that was harmless apart from not returning
the correct time, but in a real machine, it would likely lead to a
machine-check.  We never saw this problem on tiger or zx1-based
machines because by the time efi_get_time() is called, they have
switched EFI into virtual mode, which obviates the need to do the
virtual->physical conversion.

The patch below looks bigger than what's really going on: all it does
is convert __pa() to ia64_tpa(), with some extra code to allow NULL
pointers for optional arguments.

Happy hacking,

	--david

=== arch/ia64/kernel/efi.c 1.34 vs edited ==--- 1.34/arch/ia64/kernel/efi.c	2004-05-10 11:38:38 -07:00
+++ edited/arch/ia64/kernel/efi.c	2004-07-09 21:24:38 -07:00
@@ -43,18 +43,20 @@
 
 #define efi_call_virt(f, args...)	(*(f))(args)
 
-#define STUB_GET_TIME(prefix, adjust_arg)							\
-static efi_status_t										\
-prefix##_get_time (efi_time_t *tm, efi_time_cap_t *tc)						\
-{												\
-	struct ia64_fpreg fr[6];								\
-	efi_status_t ret;									\
-												\
-	ia64_save_scratch_fpregs(fr);								\
-	ret = efi_call_##prefix((efi_get_time_t *) __va(runtime->get_time), adjust_arg(tm),	\
-				adjust_arg(tc));						\
-	ia64_load_scratch_fpregs(fr);								\
-	return ret;										\
+#define STUB_GET_TIME(prefix, adjust_arg)							  \
+static efi_status_t										  \
+prefix##_get_time (efi_time_t *tm, efi_time_cap_t *tc)						  \
+{												  \
+	struct ia64_fpreg fr[6];								  \
+	efi_time_cap_t *atc = 0;								  \
+	efi_status_t ret;									  \
+												  \
+	if (tc)											  \
+		atc = adjust_arg(tc);								  \
+	ia64_save_scratch_fpregs(fr);								  \
+	ret = efi_call_##prefix((efi_get_time_t *) __va(runtime->get_time), adjust_arg(tm), atc); \
+	ia64_load_scratch_fpregs(fr);								  \
+	return ret;										  \
 }
 
 #define STUB_SET_TIME(prefix, adjust_arg)							\
@@ -89,11 +91,14 @@
 prefix##_set_wakeup_time (efi_bool_t enabled, efi_time_t *tm)					\
 {												\
 	struct ia64_fpreg fr[6];								\
+	efi_time_t *atm = 0;									\
 	efi_status_t ret;									\
 												\
+	if (tm)											\
+		atm = adjust_arg(tm);								\
 	ia64_save_scratch_fpregs(fr);								\
 	ret = efi_call_##prefix((efi_set_wakeup_time_t *) __va(runtime->set_wakeup_time),	\
-				enabled, adjust_arg(tm));					\
+				enabled, atm);							\
 	ia64_load_scratch_fpregs(fr);								\
 	return ret;										\
 }
@@ -104,11 +109,14 @@
 		       unsigned long *data_size, void *data)				\
 {											\
 	struct ia64_fpreg fr[6];							\
+	u32 *aattr = 0;									\
 	efi_status_t ret;								\
 											\
+	if (attr)									\
+		aattr = adjust_arg(attr);						\
 	ia64_save_scratch_fpregs(fr);							\
 	ret = efi_call_##prefix((efi_get_variable_t *) __va(runtime->get_variable),	\
-				adjust_arg(name), adjust_arg(vendor), adjust_arg(attr),	\
+				adjust_arg(name), adjust_arg(vendor), aattr,		\
 				adjust_arg(data_size), adjust_arg(data));		\
 	ia64_load_scratch_fpregs(fr);							\
 	return ret;									\
@@ -164,33 +172,41 @@
 		       unsigned long data_size, efi_char16_t *data)		\
 {										\
 	struct ia64_fpreg fr[6];						\
+	efi_char16_t *adata = 0;						\
+										\
+	if (data)								\
+		adata = adjust_arg(data);					\
 										\
 	ia64_save_scratch_fpregs(fr);						\
 	efi_call_##prefix((efi_reset_system_t *) __va(runtime->reset_system),	\
-			  reset_type, status, data_size, adjust_arg(data));	\
+			  reset_type, status, data_size, adata);		\
 	/* should not return, but just in case... */				\
 	ia64_load_scratch_fpregs(fr);						\
 }
 
-STUB_GET_TIME(phys, __pa)
-STUB_SET_TIME(phys, __pa)
-STUB_GET_WAKEUP_TIME(phys, __pa)
-STUB_SET_WAKEUP_TIME(phys, __pa)
-STUB_GET_VARIABLE(phys, __pa)
-STUB_GET_NEXT_VARIABLE(phys, __pa)
-STUB_SET_VARIABLE(phys, __pa)
-STUB_GET_NEXT_HIGH_MONO_COUNT(phys, __pa)
-STUB_RESET_SYSTEM(phys, __pa)
-
-STUB_GET_TIME(virt, )
-STUB_SET_TIME(virt, )
-STUB_GET_WAKEUP_TIME(virt, )
-STUB_SET_WAKEUP_TIME(virt, )
-STUB_GET_VARIABLE(virt, )
-STUB_GET_NEXT_VARIABLE(virt, )
-STUB_SET_VARIABLE(virt, )
-STUB_GET_NEXT_HIGH_MONO_COUNT(virt, )
-STUB_RESET_SYSTEM(virt, )
+#define phys_ptr(arg)	((__typeof__(arg)) ia64_tpa(arg))
+
+STUB_GET_TIME(phys, phys_ptr)
+STUB_SET_TIME(phys, phys_ptr)
+STUB_GET_WAKEUP_TIME(phys, phys_ptr)
+STUB_SET_WAKEUP_TIME(phys, phys_ptr)
+STUB_GET_VARIABLE(phys, phys_ptr)
+STUB_GET_NEXT_VARIABLE(phys, phys_ptr)
+STUB_SET_VARIABLE(phys, phys_ptr)
+STUB_GET_NEXT_HIGH_MONO_COUNT(phys, phys_ptr)
+STUB_RESET_SYSTEM(phys, phys_ptr)
+
+#define id(arg)	arg
+
+STUB_GET_TIME(virt, id)
+STUB_SET_TIME(virt, id)
+STUB_GET_WAKEUP_TIME(virt, id)
+STUB_SET_WAKEUP_TIME(virt, id)
+STUB_GET_VARIABLE(virt, id)
+STUB_GET_NEXT_VARIABLE(virt, id)
+STUB_SET_VARIABLE(virt, id)
+STUB_GET_NEXT_HIGH_MONO_COUNT(virt, id)
+STUB_RESET_SYSTEM(virt, id)
 
 void
 efi_gettimeofday (struct timespec *ts)
