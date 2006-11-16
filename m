From: akpm@osdl.org
Date: Thu, 16 Nov 2006 08:42:58 +0000
Subject: [patch 1/4] ia64 irqs: use `name' not `typename'
Message-Id: <200611160842.kAG8gwAw017740@shell0.pdx.osdl.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

From: Andrew Morton <akpm@osdl.org>

`typename' is going away and is usually uninitialised anwyay.

Cc: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Cc: "Luck, Tony" <tony.luck@intel.com>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 arch/ia64/kernel/iosapic.c |    2 +-
 arch/ia64/kernel/irq.c     |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff -puN arch/ia64/kernel/iosapic.c~ia64-irqs-use-name-not-typename arch/i=
a64/kernel/iosapic.c
--- a/arch/ia64/kernel/iosapic.c~ia64-irqs-use-name-not-typename
+++ a/arch/ia64/kernel/iosapic.c
@@ -664,7 +664,7 @@ register_intr (unsigned int gsi, int vec
 			printk(KERN_WARNING
 			       "%s: changing vector %d from %s to %s\n",
 			       __FUNCTION__, vector,
-			       idesc->chip->typename, irq_type->typename);
+			       idesc->chip->name, irq_type->name);
 		idesc->chip =3D irq_type;
 	}
 	return 0;
diff -puN arch/ia64/kernel/irq.c~ia64-irqs-use-name-not-typename arch/ia64/=
kernel/irq.c
--- a/arch/ia64/kernel/irq.c~ia64-irqs-use-name-not-typename
+++ a/arch/ia64/kernel/irq.c
@@ -76,7 +76,7 @@ int show_interrupts(struct seq_file *p,=20
 			seq_printf(p, "%10u ", kstat_cpu(j).irqs[i]);
 		}
 #endif
-		seq_printf(p, " %14s", irq_desc[i].chip->typename);
+		seq_printf(p, " %14s", irq_desc[i].chip->name);
 		seq_printf(p, "  %s", action->name);
=20
 		for (action=ACtion->next; action; action =3D action->next)
_
