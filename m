From: Thierry Reding <thierry.reding@gmail.com>
Date: Wed, 13 Aug 2014 10:28:51 +0000
Subject: [PATCH v4 1/8] ARC: Remove redundant PCI_IOBASE declaration
Message-Id: <1407925738-26170-2-git-send-email-thierry.reding@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1407925738-26170-1-git-send-email-thierry.reding@gmail.com>
In-Reply-To: <1407925738-26170-1-git-send-email-thierry.reding@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: Russell King <linux@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Stephen Boyd <sboyd@codeaurora.org>, Sam Ravnborg <sam@ravnborg.org>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, x86@kernel.org, linux-serial@vger.kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

From: Thierry Reding <treding@nvidia.com>

ARC's asm/io.h includes the asm-generic/io.h which already defines the
PCI_IOBASE variable in exactly the same way, so it can be dropped from
the architecture specific header.

Signed-off-by: Thierry Reding <treding@nvidia.com>
---
Changes in v4:
- new patch

 arch/arc/include/asm/io.h | 2 --
 1 file changed, 2 deletions(-)

diff --git a/arch/arc/include/asm/io.h b/arch/arc/include/asm/io.h
index 334ce7017a18..cabd518cb253 100644
--- a/arch/arc/include/asm/io.h
+++ b/arch/arc/include/asm/io.h
@@ -13,8 +13,6 @@
 #include <asm/byteorder.h>
 #include <asm/page.h>
 
-#define PCI_IOBASE ((void __iomem *)0)
-
 extern void __iomem *ioremap(unsigned long physaddr, unsigned long size);
 extern void __iomem *ioremap_prot(phys_addr_t offset, unsigned long size,
 				  unsigned long flags);
-- 
2.0.4

