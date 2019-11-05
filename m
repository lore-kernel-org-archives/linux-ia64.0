From: "tip-bot2 for Kees Cook" <tip-bot2@linutronix.de>
Date: Tue, 05 Nov 2019 09:27:34 +0000
Subject: [tip: x86/build] x86/vmlinux: Restore "text" Program Header with dummy section
Message-Id: <157294605427.29376.6840275918846059638.tip-bot2@tip-bot2>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191029211351.13243-8-keescook@chromium.org>
In-Reply-To: <20191029211351.13243-8-keescook@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-tip-commits@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, Borislav Petkov <bp@suse.de>, Andy Lutomirski <luto@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Dave Hansen <dave.hansen@linux.intel.com>, linux-alpha@vger.kernel.org, linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, Michael Ellerman <mpe@ellerman.id.au>, Michal Simek <monstr@monstr.eu>, Rick Edgecombe <rick.p.edgecombe@intel.com>, Segher Boessenkool <segher@kernel.crashing.org>, Will Deacon <will@kernel.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, x86-ml <x86@kernel.org>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, linux-kernel@vger.kernel.org

The following commit has been merged into the x86/build branch of tip:

Commit-ID:     7a42d41d9dc2829bdf589db855ce3f948de2da6b
Gitweb:        https://git.kernel.org/tip/7a42d41d9dc2829bdf589db855ce3f948de2da6b
Author:        Kees Cook <keescook@chromium.org>
AuthorDate:    Tue, 29 Oct 2019 14:13:29 -07:00
Committer:     Borislav Petkov <bp@suse.de>
CommitterDate: Mon, 04 Nov 2019 15:34:36 +01:00

x86/vmlinux: Restore "text" Program Header with dummy section

In a linker script, if one places a section in one or more segments using
":PHDR", then the linker will place all subsequent allocatable sections,
which do not specify ":PHDR", into the same segments. In order to have
the NOTES section in both PT_LOAD (":text") and PT_NOTE (":note"), both
segments are marked, and the only way to undo this to keep subsequent
sections out of PT_NOTE is to mark the following section with just the
single desired PT_LOAD (":text").

In preparation for having a common NOTES macro, perform the segment
assignment using a dummy section (as done by other architectures).

Signed-off-by: Kees Cook <keescook@chromium.org>
Signed-off-by: Borislav Petkov <bp@suse.de>
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
Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
Cc: x86-ml <x86@kernel.org>
Link: https://lkml.kernel.org/r/20191029211351.13243-8-keescook@chromium.org
---
 arch/x86/kernel/vmlinux.lds.S | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/arch/x86/kernel/vmlinux.lds.S b/arch/x86/kernel/vmlinux.lds.S
index e2feacf..788e789 100644
--- a/arch/x86/kernel/vmlinux.lds.S
+++ b/arch/x86/kernel/vmlinux.lds.S
@@ -147,8 +147,9 @@ SECTIONS
 	} :text = 0x9090
 
 	NOTES :text :note
+	.dummy : { *(.dummy) } :text
 
-	EXCEPTION_TABLE(16) :text = 0x9090
+	EXCEPTION_TABLE(16)
 
 	/* .text should occupy whole number of pages */
 	. = ALIGN(PAGE_SIZE);
