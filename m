From: Masahiro Yamada <yamada.masahiro@socionext.com>
Date: Mon, 12 Jun 2017 03:27:06 +0000
Subject: [PATCH 12/27] ia64: move generic-y of exported headers to uapi/asm/Kbuild
Message-Id: <1497238041-7011-13-git-send-email-yamada.masahiro@socionext.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1497238041-7011-1-git-send-email-yamada.masahiro@socionext.com>
In-Reply-To: <1497238041-7011-1-git-send-email-yamada.masahiro@socionext.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kbuild@vger.kernel.org, linux-arch <linux-arch@vger.kernel.org>
Cc: Masahiro Yamada <yamada.masahiro@socionext.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>, linux-kernel@vger.kernel.org

"generic-y += kvm_para.h" is doubled in asm/Kbuild and uapi/asm/Kbuild.
The one in the former should be simply removed because kvm_para.h is
exported.

Signed-off-by: Masahiro Yamada <yamada.masahiro@socionext.com>
---

 arch/ia64/include/asm/Kbuild | 2 --
 1 file changed, 2 deletions(-)

diff --git a/arch/ia64/include/asm/Kbuild b/arch/ia64/include/asm/Kbuild
index 502a91d8dbbd..1d7641f891e1 100644
--- a/arch/ia64/include/asm/Kbuild
+++ b/arch/ia64/include/asm/Kbuild
@@ -1,8 +1,6 @@
-
 generic-y += clkdev.h
 generic-y += exec.h
 generic-y += irq_work.h
-generic-y += kvm_para.h
 generic-y += mcs_spinlock.h
 generic-y += mm-arch-hooks.h
 generic-y += preempt.h
-- 
2.7.4

