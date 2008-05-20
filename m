From: Jes Sorensen <jes@sgi.com>
Date: Tue, 20 May 2008 09:57:58 +0000
Subject: [patch] fix zero extending for mmio ld1/2/4 emulation in KVM
Message-Id: <4832A0A6.8050800@sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------060206040307090008090108"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------060206040307090008090108
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

This one seems to solve the problem I have been seeing with ld2.acq
not being zero extended under KVM.

I believe this patch is correct - please shoot me if I am wrong.

Cheers,
Jes


--------------060206040307090008090108
Content-Type: text/plain;
 name="mmio-zero-extend.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="mmio-zero-extend.diff"

Only copy in the data actually requested by the instruction emulation
and zero pad the destination register first. This avoids the problem
where emulated mmio access got garbled data from ld2.acq instructions
in the vga console driver.

Signed-off-by: Jes Sorensen <jes@sgi.com>

---
 arch/ia64/kvm/mmio.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

Index: linux-2.6.git/arch/ia64/kvm/mmio.c
===================================================================
--- linux-2.6.git.orig/arch/ia64/kvm/mmio.c
+++ linux-2.6.git/arch/ia64/kvm/mmio.c
@@ -158,8 +158,10 @@
 	vmm_transition(vcpu);
 
 	if (p->u.ioreq.state == STATE_IORESP_READY) {
-		if (dir == IOREQ_READ)
-			*dest = p->u.ioreq.data;
+		if (dir == IOREQ_READ) {
+			*dest = 0;
+			memcpy(dest, &p->u.ioreq.data, s);
+		}
 	} else
 		panic_vm(vcpu);
 out:

--------------060206040307090008090108--
