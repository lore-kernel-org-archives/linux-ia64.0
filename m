From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Fri, 03 Sep 2010 00:49:11 +0000
Subject: [PATCH -mm 3/8] ia64: enable ARCH_DMA_ADDR_T_64BIT
Message-Id: <1283474956-14710-3-git-send-email-fujita.tomonori@lab.ntt.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <20100903094753S.fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <20100903094753S.fujita.tomonori@lab.ntt.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akpm@linux-foundation.org
Cc: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, fujita.tomonori@lab.ntt.co.jp, linux-ia64@vger.kernel.org

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: linux-ia64@vger.kernel.org
---
 arch/ia64/Kconfig |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index ba22849..5d5e32e 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -53,6 +53,9 @@ config MMU
 	bool
 	default y
 
+config ARCH_DMA_ADDR_T_64BIT
+	def_bool y
+
 config NEED_DMA_MAP_STATE
 	def_bool y
 
-- 
1.7.1

