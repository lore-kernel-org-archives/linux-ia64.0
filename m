From: Peter Foley <pefoley2@verizon.net>
Date: Tue, 26 Apr 2011 00:20:50 +0000
Subject: [PATCH] arch: ia64: don't check the toolchain if nothing is being
Message-Id: <4DB60FE2.5080701@verizon.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-kernel@vger.kernel.org
Cc: linux-ia64@vger.kernel.org, tony.luck@intel.com, fenghua.yu@intel.com

This patch disables the ia64 toolchain checks if nothing is being compiled
so targets like headers_install_all don't spew errors when they try
to compile ia64 code with a toolchain targeting a different architecture.

Signed-off-by: Peter Foley <pefoley2@verizon.net>
---
 arch/ia64/Makefile |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/arch/ia64/Makefile b/arch/ia64/Makefile
index be7bfa1..b6279a0 100644
--- a/arch/ia64/Makefile
+++ b/arch/ia64/Makefile
@@ -30,8 +30,10 @@ cflags-y	:=3D -pipe $(EXTRA) -ffixed-r13 -mfixed-range=
=F12-f15,f32-f127 \
 		   -falign-functions2 -frename-registers -fno-optimize-sibling-calls
 KBUILD_CFLAGS_KERNEL :=3D -mconstant-gp
 +ifeq ($(dot-config),1)
 GAS_STATUS	=3D $(shell $(srctree)/arch/ia64/scripts/check-gas "$(CC)" "$(O=
BJDUMP)")
 KBUILD_CPPFLAGS +=3D $(shell $(srctree)/arch/ia64/scripts/toolchain-flags =
"$(CC)" "$(OBJDUMP)" "$(READELF)")
+endif
  ifeq ($(GAS_STATUS),buggy)
 $(error Sorry, you need a newer version of the assember, one that is built=
 from	\
--=20
1.7.5.rc1

