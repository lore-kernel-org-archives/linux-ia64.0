From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Wed, 31 Oct 2007 00:45:50 +0000
Subject: [patch] Add gate.lds to list of files ignored by Git
Message-Id: <18215.53310.83055.591954@berry.ken.nicta.com.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Hi Tony,
	If you build the kernel `in-place' then do a git update, git
complains about arch/ia64/kernel/gate.lds being modified and
untracked.

This patch against Linus's head-of-tree adds that (generated) file to
a .gitignore file.

Signed-off-by: Peter Chubb <peterc@gelato.unsw.edu.au>

---
 arch/ia64/kernel/.gitignore |    1 +
 1 file changed, 1 insertion(+)

Index: linux/arch/ia64/kernel/.gitignore
=================================--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux/arch/ia64/kernel/.gitignore	2007-10-31 11:40:39.514305263 +1100
@@ -0,0 +1 @@
+gate.lds
