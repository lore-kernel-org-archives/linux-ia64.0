From: Ujjwal Kumar <ujjwalkumar0501@gmail.com>
Date: Mon, 12 Oct 2020 17:18:29 +0000
Subject: [PATCH v2 0/2] use interpreters to invoke scripts
Message-Id: <20201012170631.1241502-1-ujjwalkumar0501@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Masahiro Yamada <masahiroy@kernel.org>, Michal Marek <michal.lkml@markovi.net>
Cc: Ujjwal Kumar <ujjwalkumar0501@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Kees Cook <keescook@chromium.org>, Lukas Bulwahn <lukas.bulwahn@gmail.com>, Nathan Chancellor <natechancellor@gmail.com>, Nick Desaulniers <ndesaulniers@google.com>, linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, clang-built-linux@googlegroups.com, linux-kernel-mentees@lists.linuxfoundation.org

This patch series aims at removing the dependency on execute
bit of the scripts in the kbuild system.

If not working with fresh clone of linux-next, clean the srctree:
make distclean
make tools/clean

To test the dependency on execute bits, I tried building the
kernel after removing x-bits for all files in the repository.
Removing execute bits:
for i in $(find -executable -type f); do chmod -x $i; done

Any attempts to configure (or build) the kernel fail because of
'Permission denied' on scripts with the following error:
$ make allmodconfig
sh: ./scripts/gcc-version.sh: Permission denied
init/Kconfig:34: syntax error
init/Kconfig:33: invalid statement
init/Kconfig:34: invalid statement
sh: ./scripts/ld-version.sh: Permission denied
init/Kconfig:39: syntax error
init/Kconfig:38: invalid statement
sh: ./scripts/clang-version.sh: Permission denied
init/Kconfig:49: syntax error
init/Kconfig:48: invalid statement
make[1]: *** [scripts/kconfig/Makefile:71: allmodconfig] Error 1
make: *** [Makefile:606: allmodconfig] Error 2

Changes:
  - Adds specific interpreters (in Kconfig) to invoke
    scripts.

After this patch I could successfully do a kernel build
without any errors.

  - Again, adds specific interpreters to other parts of
    kbuild system.

I could successfully perform the following make targets after
applying the PATCH 2/2:
make headerdep
make kselftest-merge
make rpm-pkg
make perf-tar-src-pkg
make ARCH=3Dia64 defconfig
ARCH=3Darm64 CROSS_COMPILE=AArch64-linux-gnu- make prepare

Following changes in PATCH 2/2 are not yet tested:
arch/arm64/kernel/vdso32/Makefile
arch/nds32/kernel/vdso/Makefile
scripts/Makefile.build

---
Changes in v2:

  - Changes suggested by Masahiro Yamada
    $($(CONFIG_SHELL)    ->  $(shell $(CONFIG_SHELL)


Ujjwal Kumar (2):
  kconfig: use interpreters to invoke scripts
  kbuild: use interpreters to invoke scripts

 Makefile                          |  4 ++--
 arch/arm64/kernel/vdso/Makefile   |  2 +-
 arch/arm64/kernel/vdso32/Makefile |  2 +-
 arch/ia64/Makefile                |  4 ++--
 arch/nds32/kernel/vdso/Makefile   |  2 +-
 init/Kconfig                      | 16 ++++++++--------
 scripts/Makefile.build            |  2 +-
 scripts/Makefile.package          |  4 ++--
 8 files changed, 18 insertions(+), 18 deletions(-)


base-commit: 2cab4ac556258c14f6ec8d2157654e95556bbb31
--
2.25.1
