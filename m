From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Mon, 31 Mar 2008 08:32:27 +0000
Subject: [17/17][PATCH] kvm/ia64: How to boot up guests on kvm/ia64 -V8
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDC01048261@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C89309.C09C923B"
List-Id: <linux-ia64.vger.kernel.org>
References: <42DFA526FC41B1429CE7279EF83C6BDCFF7EEF@pdsmsx415.ccr.corp.intel.com>
In-Reply-To: <42DFA526FC41B1429CE7279EF83C6BDCFF7EEF@pdsmsx415.ccr.corp.intel.com>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C89309.C09C923B
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

From b04624ce5ff919d776bf1d64b157d67410c6bc27 Mon Sep 17 00:00:00 2001
From: Xiantao Zhang <xiantao.zhang@intel.com>
Date: Wed, 12 Mar 2008 13:57:33 +0800
Subject: [PATCH] KVM:IA64 : How to boot up guests on kvm/ia64

Signed-off-by: Xiantao Zhang <xiantao.zhang@intel.com>
---
 Documentation/ia64/kvm-howto.txt |   74
++++++++++++++++++++++++++++++++++++++
 1 files changed, 74 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/ia64/kvm-howto.txt

diff --git a/Documentation/ia64/kvm-howto.txt
b/Documentation/ia64/kvm-howto.txt
new file mode 100644
index 0000000..5a8049c
--- /dev/null
+++ b/Documentation/ia64/kvm-howto.txt
@@ -0,0 +1,74 @@
+				Guide: How to boot up guests on kvm/ia64
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
+	(1) If you have the guest firmware (binary)released by Intel
Corp for Xen, you can use it directly.
+	(2) If you want to build a guest firmware form source code.
Please download the source from
+		hg clone
http://xenbits.xensource.com/ext/efi-vfirmware.hg
+		Use the Guide of the source to build open Guest
Firmware.
+	(3) Rename it to Flash.fd, and copy it to /usr/local/share/qemu
+Note: For step 3, kvm use the guest firmware which complies with the
one Xen uses.
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
+5. Known possibile issue on some platforms with old Firmware
+
+If meet strange host crashes, you may try to solve it through either of
the following methods.
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
+-	srlz.d				// serialize restoration of
psr.l
++	srlz.i			// serialize restoration of psr.l
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

------_=_NextPart_001_01C89309.C09C923B
Content-Type: application/octet-stream;
	name="0017-KVM-IA64-How-to-boot-up-guests-on-kvm-ia64.patch"
Content-Transfer-Encoding: base64
Content-Description: 0017-KVM-IA64-How-to-boot-up-guests-on-kvm-ia64.patch
Content-Disposition: attachment;
	filename="0017-KVM-IA64-How-to-boot-up-guests-on-kvm-ia64.patch"

RnJvbSBiMDQ2MjRjZTVmZjkxOWQ3NzZiZjFkNjRiMTU3ZDY3NDEwYzZiYzI3IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBYaWFudGFvIFpoYW5nIDx4aWFudGFvLnpoYW5nQGludGVsLmNv
bT4KRGF0ZTogV2VkLCAxMiBNYXIgMjAwOCAxMzo1NzozMyArMDgwMApTdWJqZWN0OiBbUEFUQ0hd
IEtWTTpJQTY0IDogSG93IHRvIGJvb3QgdXAgZ3Vlc3RzIG9uIGt2bS9pYTY0CgpTaWduZWQtb2Zm
LWJ5OiBYaWFudGFvIFpoYW5nIDx4aWFudGFvLnpoYW5nQGludGVsLmNvbT4KLS0tCiBEb2N1bWVu
dGF0aW9uL2lhNjQva3ZtLWhvd3RvLnR4dCB8ICAgNzQgKysrKysrKysrKysrKysrKysrKysrKysr
KysrKysrKysrKysrKysKIDEgZmlsZXMgY2hhbmdlZCwgNzQgaW5zZXJ0aW9ucygrKSwgMCBkZWxl
dGlvbnMoLSkKIGNyZWF0ZSBtb2RlIDEwMDY0NCBEb2N1bWVudGF0aW9uL2lhNjQva3ZtLWhvd3Rv
LnR4dAoKZGlmZiAtLWdpdCBhL0RvY3VtZW50YXRpb24vaWE2NC9rdm0taG93dG8udHh0IGIvRG9j
dW1lbnRhdGlvbi9pYTY0L2t2bS1ob3d0by50eHQKbmV3IGZpbGUgbW9kZSAxMDA2NDQKaW5kZXgg
MDAwMDAwMC4uNWE4MDQ5YwotLS0gL2Rldi9udWxsCisrKyBiL0RvY3VtZW50YXRpb24vaWE2NC9r
dm0taG93dG8udHh0CkBAIC0wLDAgKzEsNzQgQEAKKwkJCQlHdWlkZTogSG93IHRvIGJvb3QgdXAg
Z3Vlc3RzIG9uIGt2bS9pYTY0CisKKzEuIEdldCB0aGUga3ZtIHNvdXJjZSBmcm9tIGdpdC5rZXJu
ZWwub3JnLgorCVVzZXJzcGFjZSBzb3VyY2U6CisJCWdpdCBjbG9uZSBnaXQ6Ly9naXQua2VybmVs
Lm9yZy9wdWIvc2NtL3ZpcnQva3ZtL2t2bS11c2Vyc3BhY2UuZ2l0CisJS2VybmVsIFNvdXJjZToK
KwkJZ2l0IGNsb25lIGdpdDovL2dpdC5rZXJuZWwub3JnL3B1Yi9zY20vbGludXgva2VybmVsL2dp
dC94aWFudGFvL2t2bS1pYTY0LmdpdAorCisyLiBDb21waWxlIHRoZSBzb3VyY2UgY29kZS4KKwky
LjEgQ29tcGlsZSB1c2Vyc3BhY2UgY29kZToKKwkJKDEpY2QgLi9rdm0tdXNlcnNwYWNlCisJCSgy
KS4vY29uZmlndXJlCisJCSgzKWNkIGtlcm5lbAorCQkoNCltYWtlIHN5bmMgTElOVVg9ICRrZXJu
ZWxfZGlyIChrZXJuZWxfZGlyIGlzIHRoZSBkaXJlY3Rvcnkgb2Yga2VybmVsIHNvdXJjZS4pCisJ
CSg1KWNkIC4uCisJCSg2KW1ha2UgcWVtdQorCQkoNyljZCBxZW11OyBtYWtlIGluc3RhbGwKKwor
CTIuMiBDb21waWxlIGtlcm5lbCBzb3VyY2UgY29kZToKKwkJKDEpIGNkIC4vJGtlcm5lbF9kaXIK
KwkJKDIpIE1ha2UgbWVudWNvbmZpZyAKKwkJKDMpIEVudGVyIGludG8gdmlydHVhbGl6YXRpb24g
b3B0aW9uLCBhbmQgY2hvb3NlIGt2bS4KKwkJKDQpIG1ha2UgCisJCSg1KSBPbmNlICg0KSBkb25l
LCBtYWtlIG1vZHVsZXNfaW5zdGFsbAorCQkoNikgTWFrZSBpbml0cmQsIGFuZCB1c2UgbmV3IGtl
cm5lbCB0byByZWJvb3QgdXAgaG9zdCBtYWNoaW5lLgorCQkoNykgT25jZSAoNikgZG9uZSwgY2Qg
JGtlcm5lbF9kaXIvYXJjaC9pYTY0L2t2bQorCQkoOCkgaW5zbW9kIGt2bS5rbzsgaW5zbW9kIGt2
bS1pbnRlbC5rbworCitOb3RlOiBGb3Igc3RlcCAyLCBwbGVhc2UgbWFrZSBzdXJlIHRoYXQgaG9z
dCBwYWdlIHNpemUgPT0gVEFSR0VUX1BBR0VfU0laRSBvZiBxZW11LCBvdGhlcndpc2UsIG1heSBm
YWlsLgorCiszLiBHZXQgR3Vlc3QgRmlybXdhcmUgbmFtZWQgYXMgRmxhc2guZmQsIGFuZCBwdXQg
aXQgdW5kZXIgcmlnaHQgcGxhY2U6CisJKDEpIElmIHlvdSBoYXZlIHRoZSBndWVzdCBmaXJtd2Fy
ZSAoYmluYXJ5KXJlbGVhc2VkIGJ5IEludGVsIENvcnAgZm9yIFhlbiwgeW91IGNhbiB1c2UgaXQg
ZGlyZWN0bHkuCisJKDIpIElmIHlvdSB3YW50IHRvIGJ1aWxkIGEgZ3Vlc3QgZmlybXdhcmUgZm9y
bSBzb3VyY2UgY29kZS4gUGxlYXNlIGRvd25sb2FkIHRoZSBzb3VyY2UgZnJvbQorCQloZyBjbG9u
ZSBodHRwOi8veGVuYml0cy54ZW5zb3VyY2UuY29tL2V4dC9lZmktdmZpcm13YXJlLmhnCisJCVVz
ZSB0aGUgR3VpZGUgb2YgdGhlIHNvdXJjZSB0byBidWlsZCBvcGVuIEd1ZXN0IEZpcm13YXJlLgor
CSgzKSBSZW5hbWUgaXQgdG8gRmxhc2guZmQsIGFuZCBjb3B5IGl0IHRvIC91c3IvbG9jYWwvc2hh
cmUvcWVtdQorTm90ZTogRm9yIHN0ZXAgMywga3ZtIHVzZSB0aGUgZ3Vlc3QgZmlybXdhcmUgd2hp
Y2ggY29tcGxpZXMgd2l0aCB0aGUgb25lIFhlbiB1c2VzLgorCis0LiBCb290IHVwIExpbnV4IG9y
IFdpbmRvd3MgZ3Vlc3RzOgorCTQuMSBDcmVhdGUgb3IgaW5zdGFsbCBhIGltYWdlIGZvciBndWVz
dCBib290LiBJZiB5b3UgaGF2ZSB4ZW4gZXhwZXJpZW5jZSwgaXQgc2hvdWxkIGJlIGVhc3kuCisK
Kwk0LjIgQm9vdCB1cCBndWVzdHMgdXNlIHRoZSBmb2xsb3dpbmcgY29tbWFuZC4KKwkJL3Vzci9s
b2NhbC9iaW4vcWVtdS1zeXN0ZW0taWE2NCAtc21wIHh4IC1tIDUxMiAtaGRhICR5b3VyX2ltYWdl
CisJCSh4eCBpcyB0aGUgbnVtYmVyIG9mIHZpcnR1YWwgcHJvY2Vzc29ycyBmb3IgdGhlIGd1ZXN0
LCBub3cgdGhlIG1heGltdW0gdmFsdWUgaXMgNCkKKworNS4gS25vd24gcG9zc2liaWxlIGlzc3Vl
IG9uIHNvbWUgcGxhdGZvcm1zIHdpdGggb2xkIEZpcm13YXJlCisKK0lmIG1lZXQgc3RyYW5nZSBo
b3N0IGNyYXNoZXMsIHlvdSBtYXkgdHJ5IHRvIHNvbHZlIGl0IHRocm91Z2ggZWl0aGVyIG9mIHRo
ZSBmb2xsb3dpbmcgbWV0aG9kcy4KKygxKTogVXBncmFkZSB5b3VyIEZpcm13YXJlIHRvIHRoZSBs
YXRlc3Qgb25lLgorCisoMik6IEFwcGx5aW5nIHRoZSBiZWxvdyBwYXRjaCB0byBrZXJuZWwgc291
cmNlLgorZGlmZiAtLWdpdCBhL2FyY2gvaWE2NC9rZXJuZWwvcGFsLlMgYi9hcmNoL2lhNjQva2Vy
bmVsL3BhbC5TCitpbmRleCAwYjUzMzQ0Li5mMDJiMGY3IDEwMDY0NAorLS0tIGEvYXJjaC9pYTY0
L2tlcm5lbC9wYWwuUworKysrIGIvYXJjaC9pYTY0L2tlcm5lbC9wYWwuUworQEAgLTg0LDcgKzg0
LDggQEAgR0xPQkFMX0VOVFJZKGlhNjRfcGFsX2NhbGxfc3RhdGljKQorIAltb3YgYXIucGZzID0g
bG9jMQorIAltb3YgcnAgPSBsb2MwCisgCTs7CistCXNybHouZAkJCQkvLyBzZXJpYWxpemUgcmVz
dG9yYXRpb24gb2YgcHNyLmwKKysJc3Jsei5pCQkJLy8gc2VyaWFsaXplIHJlc3RvcmF0aW9uIG9m
IHBzci5sCisrCTs7CisgCWJyLnJldC5zcHRrLm1hbnkgYjAKKyBFTkQoaWE2NF9wYWxfY2FsbF9z
dGF0aWMpCisKKzYuIEJ1ZyByZXBvcnQ6CisJSWYgeW91IGZvdW5kIGFueSBpc3N1ZXMgd2hlbiB1
c2Uga3ZtL2lhNjQsIFBsZWFzZSBwb3N0IHRoZSBidWcgaW5mbyB0byBrdm0taWE2NC1kZXZlbCBt
YWlsaW5nIGxpc3QuCisJaHR0cHM6Ly9saXN0cy5zb3VyY2Vmb3JnZS5uZXQvbGlzdHMvbGlzdGlu
Zm8va3ZtLWlhNjQtZGV2ZWwvCisKK1RoYW5rcyBmb3IgeW91ciBpbnRlcmVzdCEgTGV0J3Mgd29y
ayB0b2dldGhlciwgYW5kIG1ha2Uga3ZtL2lhNjQgc3Ryb25nZXIgYW5kIHN0cm9uZ2VyISAKKwor
CisJCQkJCQkJCVhpYW50YW8gWmhhbmcgPHhpYW50YW8uemhhbmdAaW50ZWwuY29tPgorCQkJCQkJ
CQkJCQkyMDA4LjMuMTAKLS0gCjEuNS4yCgo=

------_=_NextPart_001_01C89309.C09C923B--
