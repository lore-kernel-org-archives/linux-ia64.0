From: Avi Kivity <avi@redhat.com>
Date: Thu, 17 May 2012 10:14:08 +0000
Subject: [PATCH] KVM: ia64: Mark ia64 KVM as BROKEN
Message-Id: <1337249648-16894-1-git-send-email-avi@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Marcelo Tosatti <mtosatti@redhat.com>, Xiantao Zhang <xiantao.zhang@intel.com>
Cc: kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>

Practically all patches to ia64 KVM are build fixes; numerous warnings remain;
the last patch from the maintainer was committed more than three years ago.  It
is clear that no one is using this thing.

Mark as BROKEN to ensure people don't get hit by pointless build problems.

Signed-off-by: Avi Kivity <avi@redhat.com>
---
 arch/ia64/kvm/Kconfig |    1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/ia64/kvm/Kconfig b/arch/ia64/kvm/Kconfig
index 9806e55..df5351e 100644
--- a/arch/ia64/kvm/Kconfig
+++ b/arch/ia64/kvm/Kconfig
@@ -19,6 +19,7 @@ if VIRTUALIZATION
 
 config KVM
 	tristate "Kernel-based Virtual Machine (KVM) support"
+	depends on BROKEN
 	depends on HAVE_KVM && MODULES && EXPERIMENTAL
 	# for device assignment:
 	depends on PCI
-- 
1.7.10.1

