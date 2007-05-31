From: Sam Ravnborg <sam@ravnborg.org>
Date: Thu, 31 May 2007 20:17:24 +0000
Subject: [PATCH] kvm: fix section mismatch warning in kvm-intel.o
Message-Id: <20070531201724.GC27305@uranus.ravnborg.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2A01929DD3@scsmsx411.amr.corp.intel.com> <Pine.LNX.4.64.0705302019040.5583@schroedinger.engr.sgi.com> <465EE7BB.4050605@redhat.com> <20070531200446.GA27305@uranus.ravnborg.org>
In-Reply-To: <20070531200446.GA27305@uranus.ravnborg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Prarit Bhargava <prarit@redhat.com>, avi@qumranet.com
Cc: Christoph Lameter <clameter@sgi.com>, "Luck, Tony" <tony.luck@intel.com>, Randy Dunlap <randy.dunlap@oracle.com>, David Chinner <dgc@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

Fix following section mismatch warning in kvm-intel.o:
WARNING: o-i386/drivers/kvm/kvm-intel.o(.init.text+0xbd): Section mismatch: reference to .exit.text: (between 'hardware_setup' and 'vmx_disabled_by_bios')

The function free_kvm_area is used in the function alloc_kvm_area which
is marked __init.
The __exit area is discarded by some archs during link-time if a 
module is built-in resulting in an oops.

Signed-off-by: Sam Ravnborg <sam@ravnborg.org>
---
Note: This warning is only seen by my local copy of modpost
      but the change will soon hit upstream.

	Sam

diff --git a/drivers/kvm/vmx.c b/drivers/kvm/vmx.c
index e6e4d24..184238e 100644
--- a/drivers/kvm/vmx.c
+++ b/drivers/kvm/vmx.c
@@ -639,7 +639,7 @@ static void free_vmcs(struct vmcs *vmcs)
 	free_pages((unsigned long)vmcs, vmcs_descriptor.order);
 }
 
-static __exit void free_kvm_area(void)
+static void free_kvm_area(void)
 {
 	int cpu;
 
