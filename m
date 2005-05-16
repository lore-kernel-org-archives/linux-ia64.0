From: "Zhang, Yanmin" <yanmin.zhang@intel.com>
Date: Mon, 16 May 2005 01:07:25 +0000
Subject: [PATCH] Haunted spurious interrupt
Message-Id: <8126E4F969BA254AB43EA03C59F44E8402142C6A@pdsmsx404>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C559B3.D3672E87"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-kernel@vger.kernel.org
Cc: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C559B3.D3672E87
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

On my IA64 machine, after kernel 2.6.12-rc3 boots, an edge-triggered
interrupt (IRQ 46) keeps triggered over and over again. There is no IRQ
46 interrupt action handler. It has lots of impact on performance.
Kernel 2.6.10 and its prior versions have no the problem. Basically,
kernel 2.6.10 will mask the spurious edge interrupt if the interrupt is
triggered for the second time and its status includes
IRQ_DISABLE|IRQ_PENDING. Originally, IA64 kernel has its own specific
_irq_desc definitions in file arch/ia64/kernel/irq.c. The definition
initiates _irq_desc[irq].status to IRQ_DISABLE. Since kernel 2.6.11, it
was moved to architecture independent codes, i.e. kernel/irq/handle.c,
but kernel/irq/handle.c initiates _irq_desc[irq].status to 0 instead of
IRQ_DISABLE.

The attachment is a patch against kernel 2.6.12-rc3. I tested it on my
IA64 and IA32 machines.

Signed-off-by: Zhang Yanmin <yanmin.zhang@intel.com>

 <<haunted_interrupt_2.6.12-rc3.patch>>=20

------_=_NextPart_001_01C559B3.D3672E87
Content-Type: application/octet-stream;
	name="haunted_interrupt_2.6.12-rc3.patch"
Content-Transfer-Encoding: base64
Content-Description: haunted_interrupt_2.6.12-rc3.patch
Content-Disposition: attachment;
	filename="haunted_interrupt_2.6.12-rc3.patch"

ZGlmZiAtTnJhdXAgbGludXgtMi42LjEyLXJjMy9rZXJuZWwvaXJxL2hhbmRsZS5jIGxpbnV4LTIu
Ni4xMi1yYzNfZml4L2tlcm5lbC9pcnEvaGFuZGxlLmMKLS0tIGxpbnV4LTIuNi4xMi1yYzMva2Vy
bmVsL2lycS9oYW5kbGUuYwkyMDA1LTA0LTIyIDAwOjI0OjQwLjAwMDAwMDAwMCArMDgwMAorKysg
bGludXgtMi42LjEyLXJjM19maXgva2VybmVsL2lycS9oYW5kbGUuYwkyMDA1LTA1LTEyIDEyOjIx
OjE0LjkzNDMzMjc1NiArMDgwMApAQCAtMzAsNiArMzAsNyBAQAogICovCiBpcnFfZGVzY190IGly
cV9kZXNjW05SX0lSUVNdIF9fY2FjaGVsaW5lX2FsaWduZWQgPSB7CiAJWzAgLi4uIE5SX0lSUVMt
MV0gPSB7CisJCS5zdGF0dXMgPSBJUlFfRElTQUJMRUQsCiAJCS5oYW5kbGVyID0gJm5vX2lycV90
eXBlLAogCQkubG9jayA9IFNQSU5fTE9DS19VTkxPQ0tFRAogCX0K

------_=_NextPart_001_01C559B3.D3672E87--
