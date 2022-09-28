From: Masahiro Yamada <masahiroy@kernel.org>
Date: Wed, 28 Sep 2022 06:39:39 +0000
Subject: [PATCH v3 0/8] Unify <linux/export.h> and <asm/export.h>, remove EXPORT_DATA_SYMBOL(), faster TRIM_U
Message-Id: <20220928063947.299333-1-masahiroy@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kbuild@vger.kernel.org
Cc: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>, Ard Biesheuvel <ardb@kernel.org>, Nicolas Pitre <npitre@baylibre.com>, Masahiro Yamada <masahiroy@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Luis Chamberlain <mcgrof@kernel.org>, Michal Marek <michal.lkml@markovi.net>, Nathan Chancellor <nathan@kernel.org>, Nick Desaulniers <ndesaulniers@google.com>, Tom Rix <trix@redhat.com>, linux-modules@vger.kernel.org, llvm@lists.linux.dev


This patch set refactors EXPORT_SYMBOL, <linux/export.h> and <asm/export.h>.
Also, re-implement TRIM_UNUSED_KSYMS in one-pass.

You can still put EXPORT_SYMBOL() in *.S file, very close to the definition,
but you do not need to care about whether it is a function or a data.
Remove EXPORT_DATA_SYMBOL().

In v1, I broke ia64 because of missing distinction between functions and data.

V2 handles it correctly.
If the exported symbols is a function, KSYMTAB_FUNC is output.
Otherwise, KSYMTAB_DATA is output.


Changes in v3:
  - Move to the head of the series
  - New patch
  - Move struct kernel_symbol to kernel/module/internal.h
  - Some cleanups

Changes in v2:
  - New patch
  - Use KSYMTAB_FUNC and KSYMTAB_DATA for functions and data, respectively
    This distinction is needed for ia64.
  - New patch
  - New patch

Masahiro Yamada (8):
  kbuild: move modules.builtin(.modinfo) rules to Makefile.vmlinux_o
  kbuild: rebuild .vmlinux.export.o when its prerequisite is updated
  kbuild: generate KSYMTAB entries by modpost
  ia64,export.h: replace EXPORT_DATA_SYMBOL* with EXPORT_SYMBOL*
  modpost: squash sym_update_namespace() into sym_add_exported()
  modpost: use null string instead of NULL pointer for default namespace
  modpost: squash report_sec_mismatch() and remove enum mismatch
  kbuild: implement CONFIG_TRIM_UNUSED_KSYMS without recursion

 .gitignore                      |   1 -
 Makefile                        |  37 ++----
 arch/ia64/include/asm/Kbuild    |   1 +
 arch/ia64/include/asm/export.h  |   3 -
 arch/ia64/kernel/head.S         |   2 +-
 arch/ia64/kernel/ivt.S          |   2 +-
 include/asm-generic/export.h    |  83 +-----------
 include/linux/export-internal.h |  49 +++++++
 include/linux/export.h          | 114 +++-------------
 kernel/module/internal.h        |  12 ++
 scripts/Makefile.build          |  15 +--
 scripts/Makefile.modpost        |   8 +-
 scripts/Makefile.vmlinux        |  21 ++-
 scripts/Makefile.vmlinux_o      |  26 +++-
 scripts/adjust_autoksyms.sh     |  73 ----------
 scripts/basic/fixdep.c          |   3 +-
 scripts/check-local-export      |   4 +-
 scripts/gen_autoksyms.sh        |  62 ---------
 scripts/gen_ksymdeps.sh         |  30 -----
 scripts/link-vmlinux.sh         |  12 --
 scripts/mod/modpost.c           | 228 ++++++++++++++++----------------
 scripts/mod/modpost.h           |   1 +
 scripts/remove-stale-files      |   2 +
 23 files changed, 270 insertions(+), 519 deletions(-)
 delete mode 100644 arch/ia64/include/asm/export.h
 delete mode 100755 scripts/adjust_autoksyms.sh
 delete mode 100755 scripts/gen_autoksyms.sh
 delete mode 100755 scripts/gen_ksymdeps.sh

-- 
2.34.1
