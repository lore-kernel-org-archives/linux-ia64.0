From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Date: Sun, 15 Jan 2017 21:10:50 +0000
Subject: [PATCH v7 07/14] firmware: port built-in section to linker table
Message-Id: <20170115211057.17167-8-mcgrof@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170109145833.11502-1-mcgrof@kernel.org>
 <20170115211057.17167-1-mcgrof@kernel.org>
In-Reply-To: <20170115211057.17167-1-mcgrof@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: bp@alien8.de, bp@suse.de, hpa@zytor.com, acme@redhat.com, tglx@linutronix.de, mingo@redhat.com, jpoimboe@redhat.com, npiggin@gmail.com, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com, dalias@libc.org, linux@arm.linux.org.uk
Cc: x86@kernel.org, luto@amacapital.net, keescook@chromium.org, linux@roeck-us.net, torvalds@linux-foundation.org, gregkh@linuxfoundation.org, rusty@rustcorp.com.au, gnomes@lxorguk.ukuu.org.uk, alan@linux.intel.com, dwmw2@infradead.org, arnd@arndb.de, ming.lei@canonical.com, linux-arch@vger.kernel.org, benh@kernel.crashing.org, pebolle@tiscali.nl, fontana@sharpeleven.org, david.vrabel@citrix.com, konrad.wilk@oracle.com, mcb30@ipxe.org, jgross@suse.com, andrew.cooper3@citrix.com, andriy.shevchenko@linux.intel.com, paul.gortmaker@windriver.com, xen-devel@lists.xensource.com, ak@linux.intel.com, pali.rohar@gmail.com, dvhart@infradead.org, platform-driver-x86@vger.kernel.org, mmarek@suse.com, linux@rasmusvillemoes.dk, jkosina@suse.cz, korea.drzix@gmail.com, linux-kbuild@vger.kernel

This ports built-in firmware to use linker tables,
this replaces the custom section solution with a
generic solution.

This also demos the use of the .rodata linker table.

Tested with 0 built-in firmware, 1 and 2 built-in
firmwares successfully.

v6: rename table macro as suggested by Andy Shevchenko

v5:

o since we dropped SECTION_ORDER_ANY, use 'any' order level explicitly

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
index 2af69d27da62..2c5004343b45 100644
--- a/arch/x86/kernel/cpu/microcode/core.c
+++ b/arch/x86/kernel/cpu/microcode/core.c
@@ -31,6 +31,7 @@
 #include <linux/cpu.h>
 #include <linux/fs.h>
 #include <linux/mm.h>
+#include <linux/tables.h>
 
 #include <asm/microcode_intel.h>
 #include <asm/cpu_device_id.h>
@@ -110,15 +111,14 @@ static bool __init check_loader_disabled_bsp(void)
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
+	linktable_for_each(b_fw, builtin_fw) {
 		if (!strcmp(name, b_fw->name)) {
 			cd->size = b_fw->size;
 			cd->data = b_fw->data;
diff --git a/drivers/base/firmware_class.c b/drivers/base/firmware_class.c
index 4497d263209f..b9ac348e8d33 100644
--- a/drivers/base/firmware_class.c
+++ b/drivers/base/firmware_class.c
@@ -31,6 +31,7 @@
 #include <linux/reboot.h>
 #include <linux/security.h>
 #include <linux/swait.h>
+#include <linux/tables.h>
 
 #include <generated/utsrelease.h>
 
@@ -44,15 +45,14 @@ MODULE_LICENSE("GPL");
 
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
+	linktable_for_each(b_fw, builtin_fw) {
 		if (strcmp(name, b_fw->name) = 0) {
 			fw->size = b_fw->size;
 			fw->data = b_fw->data;
@@ -68,9 +68,9 @@ static bool fw_get_builtin_firmware(struct firmware *fw, const char *name,
 
 static bool fw_is_builtin_firmware(const struct firmware *fw)
 {
-	struct builtin_fw *b_fw;
+	const struct builtin_fw *b_fw;
 
-	for (b_fw = __start_builtin_fw; b_fw != __end_builtin_fw; b_fw++)
+	linktable_for_each(b_fw, builtin_fw)
 		if (fw->data = b_fw->data)
 			return true;
 
diff --git a/firmware/Makefile b/firmware/Makefile
index fa3e81c2a97b..9c8cae144ede 100644
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
+		  echo "    set_section_tbl_type(SECTION_TBL_RO, builtin_fw, any, a,$${PROGBITS})" >>$@;\
 		  echo "    .p2align $${ASM_ALIGN}"			>>$@;\
 		  echo "    $${ASM_WORD} _fw_$${FWSTR}_name"		>>$@;\
 		  echo "    $${ASM_WORD} _fw_$${FWSTR}_bin"		>>$@;\
diff --git a/include/asm-generic/vmlinux.lds.h b/include/asm-generic/vmlinux.lds.h
index ce1e9a310ada..8a5325d75932 100644
--- a/include/asm-generic/vmlinux.lds.h
+++ b/include/asm-generic/vmlinux.lds.h
@@ -324,13 +324,6 @@
 		VMLINUX_SYMBOL(__end_pci_fixups_suspend_late) = .;	\
 	}								\
 									\
-	/* Built-in firmware blobs */					\
-	.builtin_fw        : AT(ADDR(.builtin_fw) - LOAD_OFFSET) {	\
-		VMLINUX_SYMBOL(__start_builtin_fw) = .;			\
-		KEEP(*(.builtin_fw))					\
-		VMLINUX_SYMBOL(__end_builtin_fw) = .;			\
-	}								\
-									\
 	TRACEDATA							\
 									\
 	/* Kernel symbol table: Normal symbols */			\
-- 
2.11.0

