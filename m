From: mcgrof@kernel.org
Date: Fri, 19 Aug 2016 21:32:59 +0000
Subject: [PATCH v4 10/16] firmware: port built-in section to linker table
Message-Id: <1471642385-5629-11-git-send-email-mcgrof@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1471642385-5629-1-git-send-email-mcgrof@kernel.org>
In-Reply-To: <1471642385-5629-1-git-send-email-mcgrof@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, jpoimboe@redhat.com, bp@alien8.de, linux@arm.linux.org.uk, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com
Cc: gnomes@lxorguk.ukuu.org.uk, linux-ia64@vger.kernel.org, jkosina@suse.cz, benh@kernel.crashing.org, ming.lei@canonical.com, linux@rasmusvillemoes.dk, platform-driver-x86@vger.kernel.org, James.Bottomley@HansenPartnership.com, paul.gortmaker@windriver.com, paulus@samba.org, sparclinux@vger.kernel.org, Michael Matz <matz@suse.de>, Barry Song <barry.song@analog.com>, mchehab@osg.samsung.com, linux-arch@vger.kernel.org, markus.heiser@darmarit.de, xen-devel@lists.xensource.com, msalter@redhat.com, linux-sh@vger.kernel.org, mpe@ellerman.id.au, x86@kernel.org, fontana@sharpeleven.org, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, dvhart@infradead.org, dwmw2@infradead.org, Guenter Roeck <linux@roeck-us.net>, linux-xtensa@linux-xtensa.org, pali.rohar@gmail.com, Mike Frysinger <vapier@gentoo.org>, keescook@chromium.org, arnd@arndb.de, jani.nikula@intel.com, will.dea

From: "Luis R. Rodriguez" <mcgrof@kernel.org>

This ports built-in firmware to use linker tables,
this replaces the custom section solution with a
generic solution.

This also demos the use of the .rodata (SECTION_RO)
linker tables.

Tested with 0 built-in firmware, 1 and 2 built-in
firmwares successfully.

v4:

o work around c6x toolchain bug by using SECTION_TBL_RO

o fix compilation on blackfin

v3:
o explicitly include tables.h as we no longer include
  tables.h from sections.h

o use new section_tbl_asmtype() helper on firmware/Makefile
  to enable having to unfold things on our own.

v2: introduced this file in this version of the series

Cc: Barry Song <barry.song@analog.com>
Cc: Mike Frysinger <vapier@gentoo.org>
Cc: Steven Miao <realmz6@gmail.com>
Cc: Michael Matz <matz@suse.de>
Cc: Guenter Roeck <linux@roeck-us.net>
Cc: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Luis R. Rodriguez <mcgrof@kernel.org>
---
 arch/x86/kernel/cpu/microcode/core.c |  8 ++++----
 drivers/base/firmware_class.c        | 12 ++++++------
 firmware/Makefile                    |  3 ++-
 include/asm-generic/vmlinux.lds.h    |  7 -------
 4 files changed, 12 insertions(+), 18 deletions(-)

diff --git a/arch/x86/kernel/cpu/microcode/core.c b/arch/x86/kernel/cpu/microcode/core.c
index df04b2d033f6..3e7c08d99601 100644
--- a/arch/x86/kernel/cpu/microcode/core.c
+++ b/arch/x86/kernel/cpu/microcode/core.c
@@ -31,6 +31,7 @@
 #include <linux/cpu.h>
 #include <linux/fs.h>
 #include <linux/mm.h>
+#include <linux/tables.h>
 
 #include <asm/microcode_intel.h>
 #include <asm/cpu_device_id.h>
@@ -91,15 +92,14 @@ static bool __init check_loader_disabled_bsp(void)
 	return *res;
 }
 
-extern struct builtin_fw __start_builtin_fw[];
-extern struct builtin_fw __end_builtin_fw[];
+DECLARE_LINKTABLE_RO(struct builtin_fw, builtin_fw);
 
 bool get_builtin_firmware(struct cpio_data *cd, const char *name)
 {
 #ifdef CONFIG_FW_LOADER
-	struct builtin_fw *b_fw;
+	const struct builtin_fw *b_fw;
 
-	for (b_fw = __start_builtin_fw; b_fw != __end_builtin_fw; b_fw++) {
+	LINKTABLE_FOR_EACH(b_fw, builtin_fw) {
 		if (!strcmp(name, b_fw->name)) {
 			cd->size = b_fw->size;
 			cd->data = b_fw->data;
diff --git a/drivers/base/firmware_class.c b/drivers/base/firmware_class.c
index 22d1760a4278..8fbf03c3e4c2 100644
--- a/drivers/base/firmware_class.c
+++ b/drivers/base/firmware_class.c
@@ -30,6 +30,7 @@
 #include <linux/syscore_ops.h>
 #include <linux/reboot.h>
 #include <linux/security.h>
+#include <linux/tables.h>
 
 #include <generated/utsrelease.h>
 
@@ -43,15 +44,14 @@ MODULE_LICENSE("GPL");
 
 #ifdef CONFIG_FW_LOADER
 
-extern struct builtin_fw __start_builtin_fw[];
-extern struct builtin_fw __end_builtin_fw[];
+DEFINE_LINKTABLE_RO(struct builtin_fw, builtin_fw);
 
 static bool fw_get_builtin_firmware(struct firmware *fw, const char *name,
 				    void *buf, size_t size)
 {
-	struct builtin_fw *b_fw;
+	const struct builtin_fw *b_fw;
 
-	for (b_fw = __start_builtin_fw; b_fw != __end_builtin_fw; b_fw++) {
+	LINKTABLE_FOR_EACH(b_fw, builtin_fw) {
 		if (strcmp(name, b_fw->name) = 0) {
 			fw->size = b_fw->size;
 			fw->data = b_fw->data;
@@ -67,9 +67,9 @@ static bool fw_get_builtin_firmware(struct firmware *fw, const char *name,
 
 static bool fw_is_builtin_firmware(const struct firmware *fw)
 {
-	struct builtin_fw *b_fw;
+	const struct builtin_fw *b_fw;
 
-	for (b_fw = __start_builtin_fw; b_fw != __end_builtin_fw; b_fw++)
+	LINKTABLE_FOR_EACH(b_fw, builtin_fw)
 		if (fw->data = b_fw->data)
 			return true;
 
diff --git a/firmware/Makefile b/firmware/Makefile
index fa3e81c2a97b..9e701bf4ced2 100644
--- a/firmware/Makefile
+++ b/firmware/Makefile
@@ -155,6 +155,7 @@ quiet_cmd_fwbin = MK_FW   $@
 		  ASM_ALIGN=$(if $(CONFIG_64BIT),3,2);			     \
 		  PROGBITS=$(if $(CONFIG_ARM),%,@)progbits;		     \
 		  echo "/* Generated by firmware/Makefile */"		> $@;\
+		  echo "\#include <asm/tables.h>"			>>$@;\
 		  echo "    .section .rodata"				>>$@;\
 		  echo "    .p2align $${ASM_ALIGN}"			>>$@;\
 		  echo "_fw_$${FWSTR}_bin:"				>>$@;\
@@ -164,7 +165,7 @@ quiet_cmd_fwbin = MK_FW   $@
 		  echo "    .p2align $${ASM_ALIGN}"			>>$@;\
 		  echo "_fw_$${FWSTR}_name:"				>>$@;\
 		  echo "    .string \"$$FWNAME\""			>>$@;\
-		  echo "    .section .builtin_fw,\"a\",$${PROGBITS}"	>>$@;\
+		  echo "    set_section_tbl_type(SECTION_TBL_RO, builtin_fw, SECTION_ORDER_ANY, a,$${PROGBITS})" >>$@;\
 		  echo "    .p2align $${ASM_ALIGN}"			>>$@;\
 		  echo "    $${ASM_WORD} _fw_$${FWSTR}_name"		>>$@;\
 		  echo "    $${ASM_WORD} _fw_$${FWSTR}_bin"		>>$@;\
diff --git a/include/asm-generic/vmlinux.lds.h b/include/asm-generic/vmlinux.lds.h
index 4b6a3d820883..2413444c048d 100644
--- a/include/asm-generic/vmlinux.lds.h
+++ b/include/asm-generic/vmlinux.lds.h
@@ -316,13 +316,6 @@
 		VMLINUX_SYMBOL(__end_pci_fixups_suspend_late) = .;	\
 	}								\
 									\
-	/* Built-in firmware blobs */					\
-	.builtin_fw        : AT(ADDR(.builtin_fw) - LOAD_OFFSET) {	\
-		VMLINUX_SYMBOL(__start_builtin_fw) = .;			\
-		*(.builtin_fw)						\
-		VMLINUX_SYMBOL(__end_builtin_fw) = .;			\
-	}								\
-									\
 	TRACEDATA							\
 									\
 	/* Kernel symbol table: Normal symbols */			\
-- 
2.9.2

