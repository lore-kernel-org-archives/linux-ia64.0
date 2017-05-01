From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 01 May 2017 18:51:55 +0000
Subject: [PATCH] ia64: fix module loading for gcc-5.4
Message-Id: <1493664715-24051-1-git-send-email-tony.luck@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170319162019.7350-1-slyfox@gentoo.org>
In-Reply-To: <20170319162019.7350-1-slyfox@gentoo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Sergei Trofimovich <slyfox@gentoo.org>, Markus Elfring <elfring@users.sourceforge.net>, "H . J . Lu" <hjl.tools@gmail.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>

From: Sergei Trofimovich <slyfox@gentoo.org>

Starting from gcc-5.4+ gcc generates MLX
instructions in more cases to refer local
symbols:
    https://gcc.gnu.org/PR60465

That caused ia64 module loader to choke
on such instructions:
    fuse: invalid slot number 1 for IMM64

Linux kernel used to handle only case where
relocation pointed to slot=3D2 instruction in
the bundle. That limitation was fixed in linux by
commit 9c184a073bfd ("[IA64] Fix 2.6 kernel for the new ia64 assembler")
See http://sources.redhat.com/bugzilla/show_bug.cgi?id=1433

This change lifts the slot=3D2 restriction from
linux kernel module loader.

Tested on 'fuse' and 'btrfs' kernel modules.

Cc: Markus Elfring <elfring@users.sourceforge.net>
Cc: H. J. Lu <hjl.tools@gmail.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>
Bug: https://bugs.gentoo.org/601014
Tested-by: =C3=89meric MASCHINO <emeric.maschino@gmail.com>
Signed-off-by: Sergei Trofimovich <slyfox@gentoo.org>
Signed-off-by: Tony Luck <tony.luck@intel.com>
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
-	if (slot(insn) !=3D 2) {
+	if (slot(insn) !=3D 1 && slot(insn) !=3D 2) {
 		printk(KERN_ERR "%s: invalid slot number %d for IMM64\n",
 		       mod->name, slot(insn));
 		return 0;
@@ -165,7 +165,7 @@ apply_imm64 (struct module *mod, struct insn *insn, uin=
t64_t val)
 static int
 apply_imm60 (struct module *mod, struct insn *insn, uint64_t val)
 {
-	if (slot(insn) !=3D 2) {
+	if (slot(insn) !=3D 1 && slot(insn) !=3D 2) {
 		printk(KERN_ERR "%s: invalid slot number %d for IMM60\n",
 		       mod->name, slot(insn));
 		return 0;
--=20
2.7.4

