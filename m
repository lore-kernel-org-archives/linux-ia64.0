From: Masahiro Yamada <yamada.masahiro@socionext.com>
Date: Fri, 27 Mar 2015 11:43:38 +0000
Subject: [PATCH 4/4] kbuild: ia64: use $(src)/Makefile.gate rather than particular path
Message-Id: <1427456618-23830-5-git-send-email-yamada.masahiro@socionext.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1427456618-23830-1-git-send-email-yamada.masahiro@socionext.com>
In-Reply-To: <1427456618-23830-1-git-send-email-yamada.masahiro@socionext.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-kbuild@vger.kernel.org
Cc: Masahiro Yamada <yamada.masahiro@socionext.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>, linux-kernel@vger.kernel.org

Signed-off-by: Masahiro Yamada <yamada.masahiro@socionext.com>
---

 arch/ia64/kernel/Makefile | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/ia64/kernel/Makefile b/arch/ia64/kernel/Makefile
index 47e8aff..d68b5cf 100644
--- a/arch/ia64/kernel/Makefile
+++ b/arch/ia64/kernel/Makefile
@@ -51,7 +51,7 @@ obj-$(CONFIG_BINFMT_ELF)	+=3D elfcore.o
 CFLAGS_traps.o  +=3D -mfixed-range=F2-f5,f16-f31
=20
 # The gate DSO image is built using a special linker script.
-include arch/ia64/kernel/Makefile.gate
+include $(src)/Makefile.gate
 # tell compiled for native
 CPPFLAGS_gate.lds +=3D -D__IA64_GATE_PARAVIRTUALIZED_NATIVE
=20
--=20
1.9.1

