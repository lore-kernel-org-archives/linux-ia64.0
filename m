From: "tip-bot2 for Kees Cook" <tip-bot2@linutronix.de>
Date: Tue, 05 Nov 2019 09:27:35 +0000
Subject: [tip: x86/build] ia64: Rename PT_LOAD identifier "code" to "text"
Message-Id: <157294605505.29376.17632217400562285462.tip-bot2@tip-bot2>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191029211351.13243-6-keescook@chromium.org>
In-Reply-To: <20191029211351.13243-6-keescook@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-tip-commits@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, Borislav Petkov <bp@suse.de>, Andy Lutomirski <luto@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Dave Hansen <dave.hansen@linux.intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-alpha@vger.kernel.org, linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, Michal Simek <monstr@monstr.eu>, Rick Edgecombe <rick.p.edgecombe@intel.com>, Segher Boessenkool <segher@kernel.crashing.org>, Tony Luck <tony.luck@intel.com>, Will Deacon <will@kernel.org>, x86-ml <x86@kernel.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, linux-kernel@vger.kernel.org

The following commit has been merged into the x86/build branch of tip:

Commit-ID:     430c6b2647e215c4129f36646ad28a725996b410
Gitweb:        https://git.kernel.org/tip/430c6b2647e215c4129f36646ad28a725996b410
Author:        Kees Cook <keescook@chromium.org>
AuthorDate:    Tue, 29 Oct 2019 14:13:27 -07:00
Committer:     Borislav Petkov <bp@suse.de>
CommitterDate: Mon, 04 Nov 2019 15:34:29 +01:00

ia64: Rename PT_LOAD identifier "code" to "text"

In preparation for moving NOTES into RO_DATA, rename the linker script
internal identifier for the PT_LOAD Program Header from "code" to "text"
to match other architectures.

Signed-off-by: Kees Cook <keescook@chromium.org>
Signed-off-by: Borislav Petkov <bp@suse.de>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: linux-alpha@vger.kernel.org
Cc: linux-arch@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-c6x-dev@linux-c6x.org
Cc: linux-ia64@vger.kernel.org
Cc: linuxppc-dev@lists.ozlabs.org
Cc: linux-s390@vger.kernel.org
Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: Michal Simek <monstr@monstr.eu>
Cc: Rick Edgecombe <rick.p.edgecombe@intel.com>
Cc: Segher Boessenkool <segher@kernel.crashing.org>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Will Deacon <will@kernel.org>
Cc: x86-ml <x86@kernel.org>
Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
Link: https://lkml.kernel.org/r/20191029211351.13243-6-keescook@chromium.org
---
 arch/ia64/kernel/vmlinux.lds.S | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/arch/ia64/kernel/vmlinux.lds.S b/arch/ia64/kernel/vmlinux.lds.S
index d9d4e21..2c4f23c 100644
--- a/arch/ia64/kernel/vmlinux.lds.S
+++ b/arch/ia64/kernel/vmlinux.lds.S
@@ -13,7 +13,7 @@ ENTRY(phys_start)
 jiffies = jiffies_64;
 
 PHDRS {
-	code   PT_LOAD;
+	text   PT_LOAD;
 	percpu PT_LOAD;
 	data   PT_LOAD;
 	note   PT_NOTE;
@@ -36,7 +36,7 @@ SECTIONS {
 	phys_start = _start - LOAD_OFFSET;
 
 	code : {
-	} :code
+	} :text
 	. = KERNEL_START;
 
 	_text = .;
@@ -68,9 +68,9 @@ SECTIONS {
 	/*
 	 * Read-only data
 	 */
-	NOTES :code :note       /* put .notes in text and mark in PT_NOTE  */
+	NOTES :text :note       /* put .notes in text and mark in PT_NOTE  */
 	code_continues : {
-	} : code               /* switch back to regular program...  */
+	} :text                /* switch back to regular program...  */
 
 	EXCEPTION_TABLE(16)
 
@@ -102,9 +102,9 @@ SECTIONS {
 		__start_unwind = .;
 		*(.IA_64.unwind*)
 		__end_unwind = .;
-	} :code :unwind
+	} :text :unwind
 	code_continues2 : {
-	} : code
+	} :text
 
 	RODATA
 
@@ -214,7 +214,7 @@ SECTIONS {
 	_end = .;
 
 	code : {
-	} :code
+	} :text
 
 	STABS_DEBUG
 	DWARF_DEBUG
