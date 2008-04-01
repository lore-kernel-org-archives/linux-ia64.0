From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Tue, 01 Apr 2008 10:54:11 +0000
Subject: [18/18] KVM: IA64: A Guide about how to create kvm guests on ia64 V9
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDC01048731@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C893E6.B81069AB"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C893E6.B81069AB
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

From 365a0bb8b49354f9111b5745edb21b5e153784d9 Mon Sep 17 00:00:00 2001
From: Xiantao Zhang <xiantao.zhang@intel.com>
Date: Tue, 1 Apr 2008 15:08:29 +0800
Subject: [PATCH] KVM: IA64: A Guide about how to create kvm guests on
ia64

Guide for creating virtual machine on kvm/ia64.
Signed-off-by: Xiantao Zhang <xiantao.zhang@intel.com>
---
 Documentation/ia64/kvm.txt |   82
++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 82 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/ia64/kvm.txt

diff --git a/Documentation/ia64/kvm.txt b/Documentation/ia64/kvm.txt
new file mode 100644
index 0000000..a573521
--- /dev/null
+++ b/Documentation/ia64/kvm.txt
@@ -0,0 +1,82 @@
+Currently, kvm module in EXPERIMENTAL stage on IA64. This means that
+interfaces are not stable enough to use. So, plase had better don't run
+critical applications in virtual machine. We will try our best to make
it
+strong in future versions!
+				Guide: How to boot up guests on kvm/ia64
+
+This guide is to describe how to enable kvm support for IA-64 systems.
+
+1. Get the kvm source from git.kernel.org.
+	Userspace source:
+		git clone
git://git.kernel.org/pub/scm/virt/kvm/kvm-userspace.git
+	Kernel Source:
+		git clone
git://git.kernel.org/pub/scm/linux/kernel/git/xiantao/kvm-ia64.git
+
+2. Compile the source code.
+	2.1 Compile userspace code:
+		(1)cd ./kvm-userspace
+		(2)./configure
+		(3)cd kernel
+		(4)make sync LINUX=3D $kernel_dir (kernel_dir is the
directory of kernel source.)
+		(5)cd ..
+		(6)make qemu
+		(7)cd qemu; make install
+
+	2.2 Compile kernel source code:
+		(1) cd ./$kernel_dir
+		(2) Make menuconfig=20
+		(3) Enter into virtualization option, and choose kvm.
+		(4) make=20
+		(5) Once (4) done, make modules_install
+		(6) Make initrd, and use new kernel to reboot up host
machine.
+		(7) Once (6) done, cd $kernel_dir/arch/ia64/kvm
+		(8) insmod kvm.ko; insmod kvm-intel.ko
+
+Note: For step 2, please make sure that host page size =3D=3D
TARGET_PAGE_SIZE of qemu, otherwise, may fail.
+
+3. Get Guest Firmware named as Flash.fd, and put it under right place:
+	(1) If you have the guest firmware (binary) released by Intel
Corp for Xen, use it directly.
+
+	(2) If you have no firmware at hand, Please download its source
from
+		hg clone
http://xenbits.xensource.com/ext/efi-vfirmware.hg
+	    you can get the firmware's binary in the directory of
efi-vfirmware.hg/binaries.
+
+	(3) Rename the firware you owned to Flash.fd, and copy it to
/usr/local/share/qemu
+
+4. Boot up Linux or Windows guests:
+	4.1 Create or install a image for guest boot. If you have xen
experience, it should be easy.
+
+	4.2 Boot up guests use the following command.
+		/usr/local/bin/qemu-system-ia64 -smp xx -m 512 -hda
$your_image
+		(xx is the number of virtual processors for the guest,
now the maximum value is 4)
+
+5. Known possibile issue on some platforms with old Firmware.
+
+If meet strange host crashe issues, try to solve it through either of
the following ways:
+
+(1): Upgrade your Firmware to the latest one.
+
+(2): Applying the below patch to kernel source.
+diff --git a/arch/ia64/kernel/pal.S b/arch/ia64/kernel/pal.S
+index 0b53344..f02b0f7 100644
+--- a/arch/ia64/kernel/pal.S
++++ b/arch/ia64/kernel/pal.S
+@@ -84,7 +84,8 @@ GLOBAL_ENTRY(ia64_pal_call_static)
+ 	mov ar.pfs =3D loc1
+ 	mov rp =3D loc0
+ 	;;
+-	srlz.d				// seralize restoration of psr.l
++	srlz.i			// seralize restoration of psr.l
++	;;
+ 	br.ret.sptk.many b0
+ END(ia64_pal_call_static)
+
+6. Bug report:
+	If you found any issues when use kvm/ia64, Please post the bug
info to kvm-ia64-devel mailing list.
+	https://lists.sourceforge.net/lists/listinfo/kvm-ia64-devel/
+
+Thanks for your interest! Let's work together, and make kvm/ia64
stronger and stronger!=20
+
+
+								Xiantao
Zhang <xiantao.zhang@intel.com>
+
2008.3.10
--=20
1.5.2

------_=_NextPart_001_01C893E6.B81069AB
Content-Type: application/octet-stream;
	name="0018-KVM-IA64-A-Guide-about-how-to-create-kvm-guests-on.patch"
Content-Transfer-Encoding: base64
Content-Description: 0018-KVM-IA64-A-Guide-about-how-to-create-kvm-guests-on.patch
Content-Disposition: attachment;
	filename="0018-KVM-IA64-A-Guide-about-how-to-create-kvm-guests-on.patch"

RnJvbSAzNjVhMGJiOGI0OTM1NGY5MTExYjU3NDVlZGIyMWI1ZTE1Mzc4NGQ5IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBYaWFudGFvIFpoYW5nIDx4aWFudGFvLnpoYW5nQGludGVsLmNv
bT4KRGF0ZTogVHVlLCAxIEFwciAyMDA4IDE1OjA4OjI5ICswODAwClN1YmplY3Q6IFtQQVRDSF0g
S1ZNOiBJQTY0OiBBIEd1aWRlIGFib3V0IGhvdyB0byBjcmVhdGUga3ZtIGd1ZXN0cyBvbiBpYTY0
CgpHdWlkZSBmb3IgY3JlYXRpbmcgdmlydHVhbCBtYWNoaW5lIG9uIGt2bS9pYTY0LgpTaWduZWQt
b2ZmLWJ5OiBYaWFudGFvIFpoYW5nIDx4aWFudGFvLnpoYW5nQGludGVsLmNvbT4KLS0tCiBEb2N1
bWVudGF0aW9uL2lhNjQva3ZtLnR4dCB8ICAgODIgKysrKysrKysrKysrKysrKysrKysrKysrKysr
KysrKysrKysrKysrKysrKysKIDEgZmlsZXMgY2hhbmdlZCwgODIgaW5zZXJ0aW9ucygrKSwgMCBk
ZWxldGlvbnMoLSkKIGNyZWF0ZSBtb2RlIDEwMDY0NCBEb2N1bWVudGF0aW9uL2lhNjQva3ZtLnR4
dAoKZGlmZiAtLWdpdCBhL0RvY3VtZW50YXRpb24vaWE2NC9rdm0udHh0IGIvRG9jdW1lbnRhdGlv
bi9pYTY0L2t2bS50eHQKbmV3IGZpbGUgbW9kZSAxMDA2NDQKaW5kZXggMDAwMDAwMC4uYTU3MzUy
MQotLS0gL2Rldi9udWxsCisrKyBiL0RvY3VtZW50YXRpb24vaWE2NC9rdm0udHh0CkBAIC0wLDAg
KzEsODIgQEAKK0N1cnJlbnRseSwga3ZtIG1vZHVsZSBpbiBFWFBFUklNRU5UQUwgc3RhZ2Ugb24g
SUE2NC4gVGhpcyBtZWFucyB0aGF0CitpbnRlcmZhY2VzIGFyZSBub3Qgc3RhYmxlIGVub3VnaCB0
byB1c2UuIFNvLCBwbGFzZSBoYWQgYmV0dGVyIGRvbid0IHJ1bgorY3JpdGljYWwgYXBwbGljYXRp
b25zIGluIHZpcnR1YWwgbWFjaGluZS4gV2Ugd2lsbCB0cnkgb3VyIGJlc3QgdG8gbWFrZSBpdAor
c3Ryb25nIGluIGZ1dHVyZSB2ZXJzaW9ucyEKKwkJCQlHdWlkZTogSG93IHRvIGJvb3QgdXAgZ3Vl
c3RzIG9uIGt2bS9pYTY0CisKK1RoaXMgZ3VpZGUgaXMgdG8gZGVzY3JpYmUgaG93IHRvIGVuYWJs
ZSBrdm0gc3VwcG9ydCBmb3IgSUEtNjQgc3lzdGVtcy4KKworMS4gR2V0IHRoZSBrdm0gc291cmNl
IGZyb20gZ2l0Lmtlcm5lbC5vcmcuCisJVXNlcnNwYWNlIHNvdXJjZToKKwkJZ2l0IGNsb25lIGdp
dDovL2dpdC5rZXJuZWwub3JnL3B1Yi9zY20vdmlydC9rdm0va3ZtLXVzZXJzcGFjZS5naXQKKwlL
ZXJuZWwgU291cmNlOgorCQlnaXQgY2xvbmUgZ2l0Oi8vZ2l0Lmtlcm5lbC5vcmcvcHViL3NjbS9s
aW51eC9rZXJuZWwvZ2l0L3hpYW50YW8va3ZtLWlhNjQuZ2l0CisKKzIuIENvbXBpbGUgdGhlIHNv
dXJjZSBjb2RlLgorCTIuMSBDb21waWxlIHVzZXJzcGFjZSBjb2RlOgorCQkoMSljZCAuL2t2bS11
c2Vyc3BhY2UKKwkJKDIpLi9jb25maWd1cmUKKwkJKDMpY2Qga2VybmVsCisJCSg0KW1ha2Ugc3lu
YyBMSU5VWD0gJGtlcm5lbF9kaXIgKGtlcm5lbF9kaXIgaXMgdGhlIGRpcmVjdG9yeSBvZiBrZXJu
ZWwgc291cmNlLikKKwkJKDUpY2QgLi4KKwkJKDYpbWFrZSBxZW11CisJCSg3KWNkIHFlbXU7IG1h
a2UgaW5zdGFsbAorCisJMi4yIENvbXBpbGUga2VybmVsIHNvdXJjZSBjb2RlOgorCQkoMSkgY2Qg
Li8ka2VybmVsX2RpcgorCQkoMikgTWFrZSBtZW51Y29uZmlnIAorCQkoMykgRW50ZXIgaW50byB2
aXJ0dWFsaXphdGlvbiBvcHRpb24sIGFuZCBjaG9vc2Uga3ZtLgorCQkoNCkgbWFrZSAKKwkJKDUp
IE9uY2UgKDQpIGRvbmUsIG1ha2UgbW9kdWxlc19pbnN0YWxsCisJCSg2KSBNYWtlIGluaXRyZCwg
YW5kIHVzZSBuZXcga2VybmVsIHRvIHJlYm9vdCB1cCBob3N0IG1hY2hpbmUuCisJCSg3KSBPbmNl
ICg2KSBkb25lLCBjZCAka2VybmVsX2Rpci9hcmNoL2lhNjQva3ZtCisJCSg4KSBpbnNtb2Qga3Zt
LmtvOyBpbnNtb2Qga3ZtLWludGVsLmtvCisKK05vdGU6IEZvciBzdGVwIDIsIHBsZWFzZSBtYWtl
IHN1cmUgdGhhdCBob3N0IHBhZ2Ugc2l6ZSA9PSBUQVJHRVRfUEFHRV9TSVpFIG9mIHFlbXUsIG90
aGVyd2lzZSwgbWF5IGZhaWwuCisKKzMuIEdldCBHdWVzdCBGaXJtd2FyZSBuYW1lZCBhcyBGbGFz
aC5mZCwgYW5kIHB1dCBpdCB1bmRlciByaWdodCBwbGFjZToKKwkoMSkgSWYgeW91IGhhdmUgdGhl
IGd1ZXN0IGZpcm13YXJlIChiaW5hcnkpIHJlbGVhc2VkIGJ5IEludGVsIENvcnAgZm9yIFhlbiwg
dXNlIGl0IGRpcmVjdGx5LgorCisJKDIpIElmIHlvdSBoYXZlIG5vIGZpcm13YXJlIGF0IGhhbmQs
IFBsZWFzZSBkb3dubG9hZCBpdHMgc291cmNlIGZyb20KKwkJaGcgY2xvbmUgaHR0cDovL3hlbmJp
dHMueGVuc291cmNlLmNvbS9leHQvZWZpLXZmaXJtd2FyZS5oZworCSAgICB5b3UgY2FuIGdldCB0
aGUgZmlybXdhcmUncyBiaW5hcnkgaW4gdGhlIGRpcmVjdG9yeSBvZiBlZmktdmZpcm13YXJlLmhn
L2JpbmFyaWVzLgorCisJKDMpIFJlbmFtZSB0aGUgZmlyd2FyZSB5b3Ugb3duZWQgdG8gRmxhc2gu
ZmQsIGFuZCBjb3B5IGl0IHRvIC91c3IvbG9jYWwvc2hhcmUvcWVtdQorCis0LiBCb290IHVwIExp
bnV4IG9yIFdpbmRvd3MgZ3Vlc3RzOgorCTQuMSBDcmVhdGUgb3IgaW5zdGFsbCBhIGltYWdlIGZv
ciBndWVzdCBib290LiBJZiB5b3UgaGF2ZSB4ZW4gZXhwZXJpZW5jZSwgaXQgc2hvdWxkIGJlIGVh
c3kuCisKKwk0LjIgQm9vdCB1cCBndWVzdHMgdXNlIHRoZSBmb2xsb3dpbmcgY29tbWFuZC4KKwkJ
L3Vzci9sb2NhbC9iaW4vcWVtdS1zeXN0ZW0taWE2NCAtc21wIHh4IC1tIDUxMiAtaGRhICR5b3Vy
X2ltYWdlCisJCSh4eCBpcyB0aGUgbnVtYmVyIG9mIHZpcnR1YWwgcHJvY2Vzc29ycyBmb3IgdGhl
IGd1ZXN0LCBub3cgdGhlIG1heGltdW0gdmFsdWUgaXMgNCkKKworNS4gS25vd24gcG9zc2liaWxl
IGlzc3VlIG9uIHNvbWUgcGxhdGZvcm1zIHdpdGggb2xkIEZpcm13YXJlLgorCitJZiBtZWV0IHN0
cmFuZ2UgaG9zdCBjcmFzaGUgaXNzdWVzLCB0cnkgdG8gc29sdmUgaXQgdGhyb3VnaCBlaXRoZXIg
b2YgdGhlIGZvbGxvd2luZyB3YXlzOgorCisoMSk6IFVwZ3JhZGUgeW91ciBGaXJtd2FyZSB0byB0
aGUgbGF0ZXN0IG9uZS4KKworKDIpOiBBcHBseWluZyB0aGUgYmVsb3cgcGF0Y2ggdG8ga2VybmVs
IHNvdXJjZS4KK2RpZmYgLS1naXQgYS9hcmNoL2lhNjQva2VybmVsL3BhbC5TIGIvYXJjaC9pYTY0
L2tlcm5lbC9wYWwuUworaW5kZXggMGI1MzM0NC4uZjAyYjBmNyAxMDA2NDQKKy0tLSBhL2FyY2gv
aWE2NC9rZXJuZWwvcGFsLlMKKysrKyBiL2FyY2gvaWE2NC9rZXJuZWwvcGFsLlMKK0BAIC04NCw3
ICs4NCw4IEBAIEdMT0JBTF9FTlRSWShpYTY0X3BhbF9jYWxsX3N0YXRpYykKKyAJbW92IGFyLnBm
cyA9IGxvYzEKKyAJbW92IHJwID0gbG9jMAorIAk7OworLQlzcmx6LmQJCQkJLy8gc2VyYWxpemUg
cmVzdG9yYXRpb24gb2YgcHNyLmwKKysJc3Jsei5pCQkJLy8gc2VyYWxpemUgcmVzdG9yYXRpb24g
b2YgcHNyLmwKKysJOzsKKyAJYnIucmV0LnNwdGsubWFueSBiMAorIEVORChpYTY0X3BhbF9jYWxs
X3N0YXRpYykKKworNi4gQnVnIHJlcG9ydDoKKwlJZiB5b3UgZm91bmQgYW55IGlzc3VlcyB3aGVu
IHVzZSBrdm0vaWE2NCwgUGxlYXNlIHBvc3QgdGhlIGJ1ZyBpbmZvIHRvIGt2bS1pYTY0LWRldmVs
IG1haWxpbmcgbGlzdC4KKwlodHRwczovL2xpc3RzLnNvdXJjZWZvcmdlLm5ldC9saXN0cy9saXN0
aW5mby9rdm0taWE2NC1kZXZlbC8KKworVGhhbmtzIGZvciB5b3VyIGludGVyZXN0ISBMZXQncyB3
b3JrIHRvZ2V0aGVyLCBhbmQgbWFrZSBrdm0vaWE2NCBzdHJvbmdlciBhbmQgc3Ryb25nZXIhIAor
CisKKwkJCQkJCQkJWGlhbnRhbyBaaGFuZyA8eGlhbnRhby56aGFuZ0BpbnRlbC5jb20+CisJCQkJ
CQkJCQkJCTIwMDguMy4xMAotLSAKMS41LjIKCg==

------_=_NextPart_001_01C893E6.B81069AB--
