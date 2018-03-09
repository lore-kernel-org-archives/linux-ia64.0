From: Sergei Trofimovich <slyfox@gentoo.org>
Date: Fri, 09 Mar 2018 23:15:55 +0000
Subject: [PATCH v2, simpler] ia64: fix ptrace(PTRACE_GETREGS) (unbreaks strace, gdb)
Message-Id: <20180309231555.16925-1-slyfox@gentoo.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180211185134.76ccfd45@sf>
In-Reply-To: <20180211185134.76ccfd45@sf>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: Tony Luck <tony.luck@intel.com>
Cc: Sergei Trofimovich <slyfox@gentoo.org>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

The strace breakage looks like that:
./strace: get_regs: get_regs_error: Input/output error

It happens because ia64 needs to load unwind tables
to read certain registers in 'PTRACE_GETREGS'. Unwind
tables fail to load at kernel startup due to GCC quirk
on the following code (logged as PR 84184):

    extern char __end_unwind[];
    const struct unw_table_entry *end =3D (struct unw_table_entry *)table_e=
nd;
    table->end =3D segment_base + end[-1].end_offset;

GCC does not generate correct code for this single memory
reference after constant propagation.
Two triggers are required for bad code generation:
- '__end_unwind' has alignment lower (char), than
  'struct unw_table_entry' (8).
- symbol offset is negative.

This commit workarounds it by disabling inline on
init_unwind_table(). This way we avoid const-propagation
of '__end_unwind' and pass address via register.

Tested in ski (emulator) and on rx2600, rx3600 (real hardware).
In case of rx2600 it unbreaks booting.

This patch is a lighter version of patch
https://lkml.org/lkml/2018/2/2/914

CC: Tony Luck <tony.luck@intel.com>
CC: Fenghua Yu <fenghua.yu@intel.com>
CC: linux-ia64@vger.kernel.org
CC: linux-kernel@vger.kernel.org
Bug: https://github.com/strace/strace/issues/33
Bug: https://gcc.gnu.org/PR84184
Reported-by: =C3=89meric Maschino <emeric.maschino@gmail.com>
Tested-by: stanton_arch@mail.com
Signed-off-by: Sergei Trofimovich <slyfox@gentoo.org>
---
 arch/ia64/kernel/unwind.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/arch/ia64/kernel/unwind.c b/arch/ia64/kernel/unwind.c
index e04efa088902..a18190bc99a9 100644
--- a/arch/ia64/kernel/unwind.c
+++ b/arch/ia64/kernel/unwind.c
@@ -2078,7 +2078,14 @@ unw_init_from_blocked_task (struct unw_frame_info *i=
nfo, struct task_struct *t)
 }
 EXPORT_SYMBOL(unw_init_from_blocked_task);
=20
-static void
+/*
+ * We use 'noinline' to evade GCC bug https://gcc.gnu.org/PR84184
+ * where gcc code generator emits incorrect code when '__end_unwind'
+ * is const-propagated to 'end[-1].end_offset' and gcc generates
+ * incorrect code. The prigger there is negative offset relative
+ * to externally-defined symbol.
+ */
+noinline static void
 init_unwind_table (struct unw_table *table, const char *name, unsigned lon=
g segment_base,
 		   unsigned long gp, const void *table_start, const void *table_end)
 {
--=20
2.16.2

