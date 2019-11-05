From: "tip-bot2 for Kees Cook" <tip-bot2@linutronix.de>
Date: Tue, 05 Nov 2019 09:27:36 +0000
Subject: [tip: x86/build] powerpc: Remove PT_NOTE workaround
Message-Id: <157294605610.29376.1760819077288569366.tip-bot2@tip-bot2>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191029211351.13243-3-keescook@chromium.org>
In-Reply-To: <20191029211351.13243-3-keescook@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-tip-commits@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, Borislav Petkov <bp@suse.de>, Michael Ellerman <mpe@ellerman.id.au>, Andy Lutomirski <luto@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Dave Hansen <dave.hansen@linux.intel.com>, linux-alpha@vger.kernel.org, linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, Michal Simek <monstr@monstr.eu>, Rick Edgecombe <rick.p.edgecombe@intel.com>, Segher Boessenkool <segher@kernel.crashing.org>, Will Deacon <will@kernel.org>, x86@kernel.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, linux-kernel@vger.kernel.org

The following commit has been merged into the x86/build branch of tip:

Commit-ID:     6fc4000656a10fb679ab6566dcd516ee672f1706
Gitweb:        https://git.kernel.org/tip/6fc4000656a10fb679ab6566dcd516ee672f1706
Author:        Kees Cook <keescook@chromium.org>
AuthorDate:    Tue, 29 Oct 2019 14:13:24 -07:00
Committer:     Borislav Petkov <bp@suse.de>
CommitterDate: Mon, 04 Nov 2019 15:33:39 +01:00

powerpc: Remove PT_NOTE workaround

In preparation for moving NOTES into RO_DATA, remove the PT_NOTE
workaround since the kernel requires at least gcc 4.6 now.

Signed-off-by: Kees Cook <keescook@chromium.org>
Signed-off-by: Borislav Petkov <bp@suse.de>
Acked-by: Michael Ellerman <mpe@ellerman.id.au>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-alpha@vger.kernel.org
Cc: linux-arch@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-c6x-dev@linux-c6x.org
Cc: linux-ia64@vger.kernel.org
Cc: linux-s390@vger.kernel.org
Cc: linuxppc-dev@lists.ozlabs.org
Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: Michal Simek <monstr@monstr.eu>
Cc: Rick Edgecombe <rick.p.edgecombe@intel.com>
Cc: Segher Boessenkool <segher@kernel.crashing.org>
Cc: Will Deacon <will@kernel.org>
Cc: x86@kernel.org
Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
Link: https://lkml.kernel.org/r/20191029211351.13243-3-keescook@chromium.org
---
 arch/powerpc/kernel/vmlinux.lds.S | 24 ++----------------------
 1 file changed, 2 insertions(+), 22 deletions(-)

diff --git a/arch/powerpc/kernel/vmlinux.lds.S b/arch/powerpc/kernel/vmlinux.lds.S
index 81e6726..a3c8492 100644
--- a/arch/powerpc/kernel/vmlinux.lds.S
+++ b/arch/powerpc/kernel/vmlinux.lds.S
@@ -20,20 +20,6 @@ ENTRY(_stext)
 PHDRS {
 	kernel PT_LOAD FLAGS(7); /* RWX */
 	note PT_NOTE FLAGS(0);
-	dummy PT_NOTE FLAGS(0);
-
-	/* binutils < 2.18 has a bug that makes it misbehave when taking an
-	   ELF file with all segments at load address 0 as input.  This
-	   happens when running "strip" on vmlinux, because of the AT() magic
-	   in this linker script.  People using GCC >= 4.2 won't run into
-	   this problem, because the "build-id" support will put some data
-	   into the "notes" segment (at a non-zero load address).
-
-	   To work around this, we force some data into both the "dummy"
-	   segment and the kernel segment, so the dummy segment will get a
-	   non-zero load address.  It's not enough to always create the
-	   "notes" segment, since if nothing gets assigned to it, its load
-	   address will be zero.  */
 }
 
 #ifdef CONFIG_PPC64
@@ -178,14 +164,8 @@ SECTIONS
 	EXCEPTION_TABLE(0)
 
 	NOTES :kernel :note
-
-	/* The dummy segment contents for the bug workaround mentioned above
-	   near PHDRS.  */
-	.dummy : AT(ADDR(.dummy) - LOAD_OFFSET) {
-		LONG(0)
-		LONG(0)
-		LONG(0)
-	} :kernel :dummy
+	/* Restore program header away from PT_NOTE. */
+	.dummy : { *(.dummy) } :kernel
 
 /*
  * Init sections discarded at runtime
