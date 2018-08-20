From: Tony Luck <tony.luck@intel.com>
Date: Mon, 20 Aug 2018 16:31:04 +0000
Subject: [PATCH] ia64: Fix kernel BUG at lib/ioremap.c:72!
Message-Id: <20180820163104.12879-1-tony.luck@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <CAK8P3a0Jk_Q-9c7PizRF4HteigfiOprRszpaV9SCk-6tUYfVVQ@mail.gmail.com>
In-Reply-To: <CAK8P3a0Jk_Q-9c7PizRF4HteigfiOprRszpaV9SCk-6tUYfVVQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Boris Brezillon <boris.brezillon@bootlin.com>, Bjorn Helgaas <bhelgaas@google.com>, Sinan Kaya <okaya@codeaurora.org>, Tomasz Nowicki <tn@semihalf.com>, Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>, Miquel Raynal <miquel.raynal@bootlin.com>

Commit:
  0bbf47eab469 ("ia64: use asm-generic/io.h")

results in a BUG while booting ia64.  This is because
asm-generic/io.h defines PCI_IOBASE, which results in
the function acpi_pci_root_remap_iospace() doing a lot
of unnecessary (and wrong) things.

I'd suggested an #if !CONFIG_IA64 in the functon, but Arnd
suggested keeping the fix inside the arch/ia64 tree.

Fixes: 0bbf47eab469 ("ia64: use asm-generic/io.h")
Suggested-by: Arnd Bergman <arnd@arndb.de>
Signed-off-by: Tony Luck <tony.luck@intel.com>
---
 arch/ia64/include/asm/io.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/ia64/include/asm/io.h b/arch/ia64/include/asm/io.h
index 6f952171abf9..1e6fef69bb01 100644
--- a/arch/ia64/include/asm/io.h
+++ b/arch/ia64/include/asm/io.h
@@ -454,6 +454,7 @@ extern void memset_io(volatile void __iomem *s, int c, long n);
 #define xlate_dev_kmem_ptr xlate_dev_kmem_ptr
 #define xlate_dev_mem_ptr xlate_dev_mem_ptr
 #include <asm-generic/io.h>
+#undef PCI_IOBASE
 
 # endif /* __KERNEL__ */
 
-- 
2.17.1
