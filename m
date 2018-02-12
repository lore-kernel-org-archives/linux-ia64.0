From: Guenter Roeck <linux@roeck-us.net>
Date: Mon, 12 Feb 2018 22:32:13 +0000
Subject: [PATCH] ia64: Remove pci-swiotlb.o from kernel Makefile
Message-Id: <1518474733-2972-1-git-send-email-linux@roeck-us.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>, Christoph Hellwig <hch@lst.de>, =?UTF-8?q?Christian=20K=C3=B6nig?= <christian.koenig@amd.com>

Commit 4fac8076df85 ("ia64: clean up swiotlb support") removed
arch/ia64/kernel/pci-swiotlb.c but neglected to update the ia64
kernel Makefile. This results in

make[2]: *** No rule to make target 'arch/ia64/kernel/pci-swiotlb.o',
	needed by 'arch/ia64/kernel/built-in.o'.  Stop.

when trying to build ia64 images.

Fixes: 4fac8076df85 ("ia64: clean up swiotlb support")
Cc: Christoph Hellwig <hch@lst.de>
Cc: Christian K=C3=B6nig <christian.koenig@amd.com>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 arch/ia64/kernel/Makefile | 1 -
 1 file changed, 1 deletion(-)

diff --git a/arch/ia64/kernel/Makefile b/arch/ia64/kernel/Makefile
index 0b4c65a1af25..498f3da3f225 100644
--- a/arch/ia64/kernel/Makefile
+++ b/arch/ia64/kernel/Makefile
@@ -41,7 +41,6 @@ ifneq ($(CONFIG_IA64_ESI),)
 obj-y				+=3D esi_stub.o	# must be in kernel proper
 endif
 obj-$(CONFIG_INTEL_IOMMU)	+=3D pci-dma.o
-obj-$(CONFIG_SWIOTLB)		+=3D pci-swiotlb.o
=20
 obj-$(CONFIG_BINFMT_ELF)	+=3D elfcore.o
=20
--=20
2.7.4

