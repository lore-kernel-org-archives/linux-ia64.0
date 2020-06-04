From: Krzysztof Kozlowski <krzk@kernel.org>
Date: Thu, 04 Jun 2020 20:18:42 +0000
Subject: [RFT PATCH] ia64: Fix build error with !COREDUMP
Message-Id: <20200604201842.29482-1-krzk@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Tom Vaden <tom.vaden@hpe.com>, Krzysztof Kozlowski <krzk@kernel.org>, Daisuke HATAYAMA <d.hatayama@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: kbuild-all@lists.01.org, Joerg Roedel <jroedel@suse.de>, stable@vger.kernel.org

Fix linkage error when CONFIG_BINFMT_ELF is selected but CONFIG_COREDUMP
is not:

    ia64-linux-ld: arch/ia64/kernel/elfcore.o: in function `elf_core_write_=
extra_phdrs':
    elfcore.c:(.text+0x172): undefined reference to `dump_emit'
    ia64-linux-ld: arch/ia64/kernel/elfcore.o: in function `elf_core_write_=
extra_data':
    elfcore.c:(.text+0x2b2): undefined reference to `dump_emit'

Cc: <stable@vger.kernel.org>
Fixes: 1fcccbac89f5 ("elf coredump: replace ELF_CORE_EXTRA_* macros by func=
tions")
Reported-by: kernel test robot <lkp@intel.com>
Signed-off-by: Krzysztof Kozlowski <krzk@kernel.org>

---

Please let kbuild test it for a while before applying. I built it only
on few configurations.

This is similar fix to commit 42d91f612c87 ("um: Fix build error and
kconfig for i386") although I put different fixes tag - the commit which
introduced this part of code.
---
 arch/ia64/kernel/Makefile | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/ia64/kernel/Makefile b/arch/ia64/kernel/Makefile
index 1a8df6669eee..18d6008b151f 100644
--- a/arch/ia64/kernel/Makefile
+++ b/arch/ia64/kernel/Makefile
@@ -41,7 +41,7 @@ obj-y				+=3D esi_stub.o	# must be in kernel proper
 endif
 obj-$(CONFIG_INTEL_IOMMU)	+=3D pci-dma.o
=20
-obj-$(CONFIG_BINFMT_ELF)	+=3D elfcore.o
+obj-$(CONFIG_ELF_CORE)		+=3D elfcore.o
=20
 # fp_emulate() expects f2-f5,f16-f31 to contain the user-level state.
 CFLAGS_traps.o  +=3D -mfixed-range=F2-f5,f16-f31
--=20
2.17.1
