From: Jes Sorensen <jes@sgi.com>
Date: Tue, 20 May 2008 11:13:50 +0000
Subject: Re: [patch] fix zero extending for mmio ld1/2/4 emulation in KVM
Message-Id: <4832B26E.2040907@sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------090908090908020404070806"
List-Id: <linux-ia64.vger.kernel.org>
References: <4832A0A6.8050800@sgi.com>
In-Reply-To: <4832A0A6.8050800@sgi.com>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------090908090908020404070806
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Matthew Chapman wrote:
> Jes,
> 
> Glad you tracked it down.  Can I suggest rather than using memcpy, a
> more efficient way might be something like...
> 
> #define ZERO_EXTEND(x,bits) ((x) & (~0UL >> (64-(bits))))
> 
> *dest = ZERO_EXTEND(p->u.ioreq.data, 8*s);

Much nicer indeed!

Here's a pretty version - Tony will you apply this one instead.

Cheers,
Jes



--------------090908090908020404070806
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
 arch/ia64/kvm/mmio.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: linux-2.6.git/arch/ia64/kvm/mmio.c
===================================================================
--- linux-2.6.git.orig/arch/ia64/kvm/mmio.c
+++ linux-2.6.git/arch/ia64/kvm/mmio.c
@@ -159,7 +159,8 @@
 
 	if (p->u.ioreq.state == STATE_IORESP_READY) {
 		if (dir == IOREQ_READ)
-			*dest = p->u.ioreq.data;
+			/* it's necessary to ensure zero extending */
+			*dest = p->u.ioreq.data & (~0UL >> (64-(s*8)));
 	} else
 		panic_vm(vcpu);
 out:

--------------090908090908020404070806--
