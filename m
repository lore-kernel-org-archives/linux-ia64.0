From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Thu, 17 Dec 2009 12:50:55 +0000
Subject: [PATCH] vhost: add missing architectures
Message-Id: <20091217125055.GA26718@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: rusty@rustcorp.com.au, virtualization@lists.linux-foundation.org
Cc: Avi Kivity <avi@redhat.com>, Marcelo Tosatti <mtosatti@redhat.com>, Xiantao Zhang <xiantao.zhang@intel.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "Michael S. Tsirkin" <mst@redhat.com>, Gleb Natapov <gleb@redhat.com>, Hollis Blanchard <hollisb@us.ibm.com>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Carsten Otte <cotte@de.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, linux390@de.ibm.com, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, kvm@vger.kernel.org, kvm-ia64@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, kvm-ppc@vger.kernel.org, linux-s390@vger.kernel.org

vhost is completely portable, but Kconfig include was missing for all
architectures besides x86, so it did not appear in the menu.  Add the
relevant Kconfig includes to all architectures that support
virtualization.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---

Hi Rusty,
please apply the following trivial fixup patch for 2.6.33.
Thanks!

 arch/ia64/kvm/Kconfig    |    1 +
 arch/powerpc/kvm/Kconfig |    1 +
 arch/s390/kvm/Kconfig    |    1 +
 3 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/arch/ia64/kvm/Kconfig b/arch/ia64/kvm/Kconfig
index ef3e7be..01c7579 100644
--- a/arch/ia64/kvm/Kconfig
+++ b/arch/ia64/kvm/Kconfig
@@ -47,6 +47,7 @@ config KVM_INTEL
 	  Provides support for KVM on Itanium 2 processors equipped with the VT
 	  extensions.
 
+source drivers/vhost/Kconfig
 source drivers/virtio/Kconfig
 
 endif # VIRTUALIZATION
diff --git a/arch/powerpc/kvm/Kconfig b/arch/powerpc/kvm/Kconfig
index c299268..a1b4c5d 100644
--- a/arch/powerpc/kvm/Kconfig
+++ b/arch/powerpc/kvm/Kconfig
@@ -58,6 +58,7 @@ config KVM_E500
 
 	  If unsure, say N.
 
+source drivers/vhost/Kconfig
 source drivers/virtio/Kconfig
 
 endif # VIRTUALIZATION
diff --git a/arch/s390/kvm/Kconfig b/arch/s390/kvm/Kconfig
index bf164fc..6be6aea 100644
--- a/arch/s390/kvm/Kconfig
+++ b/arch/s390/kvm/Kconfig
@@ -36,6 +36,7 @@ config KVM
 
 # OK, it's a little counter-intuitive to do this, but it puts it neatly under
 # the virtualization menu.
+source drivers/vhost/Kconfig
 source drivers/virtio/Kconfig
 
 endif # VIRTUALIZATION
-- 
1.6.6.rc1.43.gf55cc
