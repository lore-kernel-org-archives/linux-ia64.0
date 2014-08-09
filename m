From: Daniele Forsi <dforsi@gmail.com>
Date: Sat, 09 Aug 2014 09:40:41 +0000
Subject: [PATCH] arch/ia64: remove comments that do not match the corresponding #ifdef
Message-Id: <1407577241-4085-1-git-send-email-dforsi@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Remove these comments instead of fixing them because the other 28 #endif's
in this source file do not have comments.

Signed-off-by: Daniele Forsi <dforsi@gmail.com>
---
Looking at git blame, I found that:
CONFIG_PROC_VMCORE wasn't updated in commit d9a9855d0=C2=A0(always reserve
elfcore header memory in crash kernel) that changed the #ifdef;
CONFIG_APCI_BOOT (there's a typo APCI vs ACPI) wasn't updated in commit
888ba6c62 ([ACPI] delete CONFIG_ACPI_BOOT) that changed the #ifdef.

 arch/ia64/kernel/setup.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index d86669b..38bfcfc 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -521,7 +521,7 @@ int __init reserve_elfcorehdr(u64 *start, u64 *end)
 	return 0;
 }
=20
-#endif /* CONFIG_PROC_VMCORE */
+#endif
=20
 void __init
 setup_arch (char **cmdline_p)
@@ -566,7 +566,7 @@ setup_arch (char **cmdline_p)
 		32 : cpus_weight(early_cpu_possible_map)),
 		additional_cpus > 0 ? additional_cpus : 0);
 # endif
-#endif /* CONFIG_APCI_BOOT */
+#endif
=20
 #ifdef CONFIG_SMP
 	smp_build_cpu_map();
--=20
2.0.1

