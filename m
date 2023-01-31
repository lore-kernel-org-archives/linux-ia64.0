From: Al Viro <viro@zeniv.linux.org.uk>
Date: Tue, 31 Jan 2023 20:06:05 +0000
Subject: [PATCH 07/10] openrisc: fix livelock in uaccess
Message-Id: <Y9l0rfNESGOhIf9E@ZenIV>
List-Id: <linux-ia64.vger.kernel.org>
References: <Y9lz6yk113LmC9SI@ZenIV>
In-Reply-To: <Y9lz6yk113LmC9SI@ZenIV>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arch@vger.kernel.org
Cc: linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-m68k@lists.linux-m68k.org, Michal Simek <monstr@monstr.eu>, Dinh Nguyen <dinguyen@kernel.org>, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linux-riscv@lists.infradead.org, sparclinux@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>

openrisc equivalent of 26178ec11ef3 "x86: mm: consolidate VM_FAULT_RETRY handling"
If e.g. get_user() triggers a page fault and a fatal signal is caught, we might
end up with handle_mm_fault() returning VM_FAULT_RETRY and not doing anything
to page tables.  In such case we must *not* return to the faulting insn -
that would repeat the entire thing without making any progress; what we need
instead is to treat that as failed (user) memory access.

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 arch/openrisc/mm/fault.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/arch/openrisc/mm/fault.c b/arch/openrisc/mm/fault.c
index b4762d66e9ef..6734fee3134f 100644
--- a/arch/openrisc/mm/fault.c
+++ b/arch/openrisc/mm/fault.c
@@ -162,8 +162,11 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long address,
 
 	fault = handle_mm_fault(vma, address, flags, regs);
 
-	if (fault_signal_pending(fault, regs))
+	if (fault_signal_pending(fault, regs)) {
+		if (!user_mode(regs))
+			goto no_context;
 		return;
+	}
 
 	/* The fault is fully completed (including releasing mmap lock) */
 	if (fault & VM_FAULT_COMPLETED)
-- 
2.30.2
