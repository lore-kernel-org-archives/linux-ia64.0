From: Russell King <rmk+kernel@arm.linux.org.uk>
Date: Thu, 28 Apr 2016 09:28:24 +0000
Subject: [PATCH 08/12] kexec: don't invoke OOM-killer for control page allocation
Message-Id: <E1aviFE-0000jS-UI@rmk-PC.arm.linux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160428092644.GX19428@n2100.arm.linux.org.uk>
In-Reply-To: <20160428092644.GX19428@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org
Cc: devicetree@vger.kernel.org, Eric Biederman <ebiederm@xmission.com>, Fenghua Yu <fenghua.yu@intel.com>, Haren Myneni <hbabu@us.ibm.com>, Ian Campbell <ijc+devicetree@hellion.org.uk>, Jonathan Corbet <corbet@lwn.net>, kexec@lists.infradead.org, Kumar Gala <galak@codeaurora.org>, linux-doc@vger.kernel.org, linux-ia64@vger.kernel.org, Mark Rutland <mark.rutland@arm.com>, Pawel Moll <pawel.moll@arm.com>, Rob Herring <robh+dt@kernel.org>, Santosh Shilimkar <ssantosh@kernel.org>, Tony Luck <tony.luck@intel.com>, Vivek Goyal <vgoyal@redhat.com>

If we are unable to find a suitable page when allocating the control
page, do not invoke the OOM-killer: killing processes probably isn't
going to help.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 include/linux/kexec.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/kexec.h b/include/linux/kexec.h
index 2cc643c6e870..1b32ab587f66 100644
--- a/include/linux/kexec.h
+++ b/include/linux/kexec.h
@@ -41,7 +41,7 @@
 #endif
 
 #ifndef KEXEC_CONTROL_MEMORY_GFP
-#define KEXEC_CONTROL_MEMORY_GFP GFP_KERNEL
+#define KEXEC_CONTROL_MEMORY_GFP (GFP_KERNEL | __GFP_NORETRY)
 #endif
 
 #ifndef KEXEC_CONTROL_PAGE_SIZE
-- 
2.1.0

