From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 07 Aug 2019 23:07:37 +0000
Subject: Re: remove sn2, hpsim and ia64 machvecs
Message-Id: <20190807230737.GA11458@agluck-desk2.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190807133049.20893-1-hch@lst.de>
 <3908561D78D1C84285E8C5FCA982C28F7F41388B@ORSMSX115.amr.corp.intel.com>
 <3908561D78D1C84285E8C5FCA982C28F7F4143CB@ORSMSX115.amr.corp.intel.com>
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F7F4143CB@ORSMSX115.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Christoph Hellwig' <hch@lst.de>, "Yu, Fenghua" <fenghua.yu@intel.com>
Cc: 'Arnd Bergmann' <arnd@arndb.de>, 'Greg Kroah-Hartman' <gregkh@linuxfoundation.org>, "'linux-ia64@vger.kernel.org'" <linux-ia64@vger.kernel.org>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>

On Wed, Aug 07, 2019 at 01:26:17PM -0700, Luck, Tony wrote:
> Ugh! The rule to do the compression was in arch/ia64/hp/sim/boot/Makefile
> which went away as part of the deletion of hpsim.

This fixes it ... should fold into the patch that dropped the
arch/ia64/hp/sim/boot/Makefile

I just cut/pasted in those cmd_gzip and cmd_objcopy definitions
from elsewhere in the tree. It might be possible to simplify them.

---
 arch/ia64/Makefile | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/arch/ia64/Makefile b/arch/ia64/Makefile
index 6eaa0ffd15ca..e0bb2b6aaa35 100644
--- a/arch/ia64/Makefile
+++ b/arch/ia64/Makefile
@@ -39,6 +39,12 @@ $(error Sorry, you need a newer version of the assember, one that is built from
 		ftp://ftp.hpl.hp.com/pub/linux-ia64/gas-030124.tar.gz)
 endif
 
+quiet_cmd_gzip = GZIP    $@
+cmd_gzip = cat $(real-prereqs) | gzip -n -f -9 > $@
+
+quiet_cmd_objcopy = OBJCOPY $@
+cmd_objcopy = $(OBJCOPY) $(OBJCOPYFLAGS) $(OBJCOPYFLAGS_$(@F)) $< $@
+
 KBUILD_CFLAGS += $(cflags-y)
 head-y := arch/ia64/kernel/head.o
 
@@ -57,7 +63,11 @@ compressed: vmlinux.gz
 
 vmlinuz: vmlinux.gz
 
-vmlinux.gz: vmlinux
+vmlinux.gz: vmlinux.bin FORCE
+	$(call if_changed,gzip)
+
+vmlinux.bin: vmlinux FORCE
+	$(call if_changed,objcopy)
 
 unwcheck: vmlinux
 	-$(Q)READELF=$(READELF) $(PYTHON) $(srctree)/arch/ia64/scripts/unwcheck.py $<
-- 
2.20.1
