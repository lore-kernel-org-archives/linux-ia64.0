From: Sergei Trofimovich <slyfox@gentoo.org>
Date: Sun, 19 Mar 2017 16:20:19 +0000
Subject: [PATCH] ia64: fix module loading for gcc-5.4
Message-Id: <20170319162019.7350-1-slyfox@gentoo.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>
Cc: Sergei Trofimovich <slyfox@gentoo.org>, "H . J . Lu" <hjl.tools@gmail.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Starting from gcc-5.4+ gcc geperates MLX
instructions in more cases to refer local
symbols:
    https://gcc.gnu.org/bugzilla/60465

That caused ia64 module loader to choke
on such instructions:
    fuse: invalid slot number 1 for IMM64

Linux kernel used to handle only case where
relocation pointed to slot=2 instruction in
the bundle. That limitation was fixed in linux
by 9c184a073bfd650cc791956d6ca79725bb682716 commit.
See http://sources.redhat.com/bugzilla/show_bug.cgi?id33

This change lifts the slot=2 restriction from
linux kernel module loader.

Tested on 'fuse' and 'btrfs' kernel modules.

Cc: H. J. Lu <hjl.tools@gmail.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Bug: https://bugs.gentoo.org/601014
Signed-off-by: Sergei Trofimovich <slyfox@gentoo.org>
---
 arch/ia64/kernel/module.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/kernel/module.c b/arch/ia64/kernel/module.c
index 6ab0ae7d6535..d1d945c6bd05 100644
--- a/arch/ia64/kernel/module.c
+++ b/arch/ia64/kernel/module.c
@@ -153,7 +153,7 @@ slot (const struct insn *insn)
 static int
 apply_imm64 (struct module *mod, struct insn *insn, uint64_t val)
 {
-	if (slot(insn) != 2) {
+	if (slot(insn) != 1 && slot(insn) != 2) {
 		printk(KERN_ERR "%s: invalid slot number %d for IMM64\n",
 		       mod->name, slot(insn));
 		return 0;
@@ -165,7 +165,7 @@ apply_imm64 (struct module *mod, struct insn *insn, uint64_t val)
 static int
 apply_imm60 (struct module *mod, struct insn *insn, uint64_t val)
 {
-	if (slot(insn) != 2) {
+	if (slot(insn) != 1 && slot(insn) != 2) {
 		printk(KERN_ERR "%s: invalid slot number %d for IMM60\n",
 		       mod->name, slot(insn));
 		return 0;
-- 
2.12.0

