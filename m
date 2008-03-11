From: Masami Hiramatsu <mhiramat@redhat.com>
Date: Tue, 11 Mar 2008 00:06:48 +0000
Subject: [PATCH -mm] kprobes: fix prepare_booster to get correct slot
Message-Id: <47D5CD18.4080400@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <47D166E7.2050803@redhat.com> <1205120600.20271.3.camel@sli10-desk.sh.intel.com> <47D57D28.7070100@redhat.com>
In-Reply-To: <47D57D28.7070100@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, ia64 <linux-ia64@vger.kernel.org>, "Luck, Tony" <tony.luck@intel.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@us.ibm.com>, systemtap-ml <systemtap@sources.redhat.com>

Fix to get correct slot number from probing address
in prepare_booster.

Signed-off-by: Masami Hiramatsu <mhiramat@redhat.com>
---
Andrew, this is a bugfix of
kprobes-kprobe-booster-for-ia64.patch

 arch/ia64/kernel/kprobes.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: 2.6.25-rc3-mm1/arch/ia64/kernel/kprobes.c
=================================--- 2.6.25-rc3-mm1.orig/arch/ia64/kernel/kprobes.c
+++ 2.6.25-rc3-mm1/arch/ia64/kernel/kprobes.c
@@ -565,7 +565,7 @@ static int __kprobes can_boost(bundle_t
 static void __kprobes prepare_booster(struct kprobe *p)
 {
 	unsigned long addr = (unsigned long)p->addr & ~0xFULL;
-	unsigned int slot = addr & 0xf;
+	unsigned int slot = (unsigned long)p->addr & 0xf;
 	struct kprobe *other_kp;

 	if (can_boost(&p->ainsn.insn[0].bundle, slot, addr)) {
