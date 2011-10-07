From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 07 Oct 2011 21:54:53 +0000
Subject: New name for ia64/pstore tree/branch for linux-next
Message-Id: <4e8f752d15504184d7@agluck-desktop.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I'm up and running on the new improved kernel.org - but I took the opportunity to
shed the "-2.6" from my git tree name, and also changed the name of the
branch you should pull from "test" to "next".

Since there are non-ia64 bits in it, perhaps you might want to change the
first field as well to "ia64-pstore"???

-Tony

---

diff --git a/Next/Trees b/Next/Trees
index df333c1..2888186 100644
--- a/Next/Trees
+++ b/Next/Trees
@@ -46,7 +46,7 @@ xilinx		git	git://git.xilinx.com/linux-2.6-xlnx.git#arm-next
 blackfin	git	git://git.kernel.org/pub/scm/linux/kernel/git/vapier/blackfin.git#for-linus
 cris		git	git://www.jni.nu/cris.git#for-next
 hexagon		quilt	https://www.codeaurora.org/patches/quic/hlk/hexagon-linux-20110916/
-ia64		git	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git#test
+ia64		git	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git#next
 m68k		git	git://git.kernel.org/pub/scm/linux/kernel/git/geert/linux-m68k.git#for-next
 m68knommu	git	git://git.kernel.org/pub/scm/linux/kernel/git/gerg/m68knommu.git#for-next
 microblaze	git	git://git.monstr.eu/linux-2.6-microblaze.git#next
