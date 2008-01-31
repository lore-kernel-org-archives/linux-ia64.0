From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Thu, 31 Jan 2008 10:30:47 +0000
Subject: [PATCH][21] Readme for kvm/ia64 boot.
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDCD31FD8@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C863F4.57B96D7B"
List-Id: <linux-ia64.vger.kernel.org>
To: Avi Kivity <avi@qumranet.com>, "Luck, Tony" <tony.luck@intel.com>, "Xu, Anthony" <anthony.xu@intel.com>, "Zhang, Xiantao" <xiantao.zhang@intel.com>
Cc: kvm-devel@lists.sourceforge.net, kvm-ia64-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C863F4.57B96D7B
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

From: Zhang Xiantao <xiantao.zhang@intel.com>
Date: Tue, 29 Jan 2008 17:27:06 +0800
Subject: [PATCH] README: How to boot up guests on kvm/ia64

Guide: How to boot up guests on kvm/ia64
Signed-off-by: Xiantao Zhang <xiantao.zhang@intel.com>
---
 arch/ia64/kvm/README |   72
++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 72 insertions(+), 0 deletions(-)
 create mode 100644 arch/ia64/kvm/README

diff --git a/arch/ia64/kvm/README b/arch/ia64/kvm/README
new file mode 100644
index 0000000..22b1db7
--- /dev/null
+++ b/arch/ia64/kvm/README
@@ -0,0 +1,72 @@
+				Guide: How to boot up guests on kvm/ia64
+
+1. Get the kvm source from git.kernel.org.
+	Userspace source:
+		git clone
git://git.kernel.org/pub/scm/virt/kvm/kvm-userspace.git
+	Kernel Source:
+		git clone
git://git.kernel.org/pub/scm/linux/kernel/git/avi/kvm.git
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
+	(2) If you want to build a guest firmware form souce code.
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
+5. Known possbile issue on some platforms with old Firmware
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
+								Zhang
Xiantao <xiantao.zhang@intel.com>
+
2008.1.28
--=20
1.5.1

------_=_NextPart_001_01C863F4.57B96D7B
Content-Type: application/octet-stream;
	name="0021-README-How-to-boot-up-guests-on-kvm-ia64.patch"
Content-Transfer-Encoding: base64
Content-Description: 0021-README-How-to-boot-up-guests-on-kvm-ia64.patch
Content-Disposition: attachment;
	filename="0021-README-How-to-boot-up-guests-on-kvm-ia64.patch"

RnJvbSAwMzU0OWY2MzlmNTAyZTNmYjJjZGU0NjlmNjM3NTMzYmMzMGQ3OTZjIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBaaGFuZyBYaWFudGFvIDx4aWFudGFvLnpoYW5nQGludGVsLmNv
bT4KRGF0ZTogVHVlLCAyOSBKYW4gMjAwOCAxNzoyNzowNiArMDgwMApTdWJqZWN0OiBbUEFUQ0hd
IFJFQURNRTogSG93IHRvIGJvb3QgdXAgZ3Vlc3RzIG9uIGt2bS9pYTY0CgpHdWlkZTogSG93IHRv
IGJvb3QgdXAgZ3Vlc3RzIG9uIGt2bS9pYTY0ClNpZ25lZC1vZmYtYnk6IFhpYW50YW8gWmhhbmcg
PHhpYW50YW8uemhhbmdAaW50ZWwuY29tPgotLS0KIGFyY2gvaWE2NC9rdm0vUkVBRE1FIHwgICA3
MiArKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKwogMSBm
aWxlcyBjaGFuZ2VkLCA3MiBpbnNlcnRpb25zKCspLCAwIGRlbGV0aW9ucygtKQogY3JlYXRlIG1v
ZGUgMTAwNjQ0IGFyY2gvaWE2NC9rdm0vUkVBRE1FCgpkaWZmIC0tZ2l0IGEvYXJjaC9pYTY0L2t2
bS9SRUFETUUgYi9hcmNoL2lhNjQva3ZtL1JFQURNRQpuZXcgZmlsZSBtb2RlIDEwMDY0NAppbmRl
eCAwMDAwMDAwLi4yMmIxZGI3Ci0tLSAvZGV2L251bGwKKysrIGIvYXJjaC9pYTY0L2t2bS9SRUFE
TUUKQEAgLTAsMCArMSw3MiBAQAorCQkJCUd1aWRlOiBIb3cgdG8gYm9vdCB1cCBndWVzdHMgb24g
a3ZtL2lhNjQKKworMS4gR2V0IHRoZSBrdm0gc291cmNlIGZyb20gZ2l0Lmtlcm5lbC5vcmcuCisJ
VXNlcnNwYWNlIHNvdXJjZToKKwkJZ2l0IGNsb25lIGdpdDovL2dpdC5rZXJuZWwub3JnL3B1Yi9z
Y20vdmlydC9rdm0va3ZtLXVzZXJzcGFjZS5naXQKKwlLZXJuZWwgU291cmNlOgorCQlnaXQgY2xv
bmUgZ2l0Oi8vZ2l0Lmtlcm5lbC5vcmcvcHViL3NjbS9saW51eC9rZXJuZWwvZ2l0L2F2aS9rdm0u
Z2l0CisyLiBDb21waWxlIHRoZSBzb3VyY2UgY29kZS4KKwkyLjEgQ29tcGlsZSB1c2Vyc3BhY2Ug
Y29kZToKKwkJKDEpY2QgLi9rdm0tdXNlcnNwYWNlCisJCSgyKS4vY29uZmlndXJlCisJCSgzKWNk
IGtlcm5lbAorCQkoNCltYWtlIHN5bmMgTElOVVg9ICRrZXJuZWxfZGlyIChrZXJuZWxfZGlyIGlz
IHRoZSBkaXJlY3Rvcnkgb2Yga2VybmVsIHNvdXJjZS4pCisJCSg1KWNkIC4uCisJCSg2KW1ha2Ug
cWVtdQorCQkoNyljZCBxZW11OyBtYWtlIGluc3RhbGwKKwkyLjIgQ29tcGlsZSBrZXJuZWwgc291
cmNlIGNvZGU6CisJCSgxKSBjZCAuLyRrZXJuZWxfZGlyCisJCSgyKSBNYWtlIG1lbnVjb25maWcg
CisJCSgzKSBFbnRlciBpbnRvIHZpcnR1YWxpemF0aW9uIG9wdGlvbiwgYW5kIGNob29zZSBrdm0u
CisJCSg0KSBtYWtlIAorCQkoNSkgT25jZSAoNCkgZG9uZSwgbWFrZSBtb2R1bGVzX2luc3RhbGwK
KwkJKDYpIE1ha2UgaW5pdHJkLCBhbmQgdXNlIG5ldyBrZXJuZWwgdG8gcmVib290IHVwIGhvc3Qg
bWFjaGluZS4KKwkJKDcpIE9uY2UgKDYpIGRvbmUsIGNkICRrZXJuZWxfZGlyL2FyY2gvaWE2NC9r
dm0KKwkJKDgpIGluc21vZCBrdm0ua287IGluc21vZCBrdm0taW50ZWwua28KKworTm90ZTogRm9y
IHN0ZXAgMiwgcGxlYXNlIG1ha2Ugc3VyZSB0aGF0IGhvc3QgcGFnZSBzaXplID09IFRBUkdFVF9Q
QUdFX1NJWkUgb2YgcWVtdSwgb3RoZXJ3aXNlLCBtYXkgZmFpbC4KKworMy4gR2V0IEd1ZXN0IEZp
cm13YXJlIG5hbWVkIGFzIEZsYXNoLmZkLCBhbmQgcHV0IGl0IHVuZGVyIHJpZ2h0IHBsYWNlOgor
CSgxKSBJZiB5b3UgaGF2ZSB0aGUgZ3Vlc3QgZmlybXdhcmUgKGJpbmFyeSlyZWxlYXNlZCBieSBJ
bnRlbCBDb3JwIGZvciBYZW4sIHlvdSBjYW4gdXNlIGl0IGRpcmVjdGx5LgorCSgyKSBJZiB5b3Ug
d2FudCB0byBidWlsZCBhIGd1ZXN0IGZpcm13YXJlIGZvcm0gc291Y2UgY29kZS4gUGxlYXNlIGRv
d25sb2FkIHRoZSBzb3VyY2UgZnJvbQorCQloZyBjbG9uZSBodHRwOi8veGVuYml0cy54ZW5zb3Vy
Y2UuY29tL2V4dC9lZmktdmZpcm13YXJlLmhnCisJCVVzZSB0aGUgR3VpZGUgb2YgdGhlIHNvdXJj
ZSB0byBidWlsZCBvcGVuIEd1ZXN0IEZpcm13YXJlLgorCSgzKSBSZW5hbWUgaXQgdG8gRmxhc2gu
ZmQsIGFuZCBjb3B5IGl0IHRvIC91c3IvbG9jYWwvc2hhcmUvcWVtdQorTm90ZTogRm9yIHN0ZXAg
Mywga3ZtIHVzZSB0aGUgZ3Vlc3QgZmlybXdhcmUgd2hpY2ggY29tcGxpZXMgd2l0aCB0aGUgb25l
IFhlbiB1c2VzLgorCis0LiBCb290IHVwIExpbnV4IG9yIFdpbmRvd3MgZ3Vlc3RzOgorCTQuMSBD
cmVhdGUgb3IgaW5zdGFsbCBhIGltYWdlIGZvciBndWVzdCBib290LiBJZiB5b3UgaGF2ZSB4ZW4g
ZXhwZXJpZW5jZSwgaXQgc2hvdWxkIGJlIGVhc3kuCisKKwk0LjIgQm9vdCB1cCBndWVzdHMgdXNl
IHRoZSBmb2xsb3dpbmcgY29tbWFuZC4KKwkJL3Vzci9sb2NhbC9iaW4vcWVtdS1zeXN0ZW0taWE2
NCAtc21wIHh4IC1tIDUxMiAtaGRhICR5b3VyX2ltYWdlCisJCSh4eCBpcyB0aGUgbnVtYmVyIG9m
IHZpcnR1YWwgcHJvY2Vzc29ycyBmb3IgdGhlIGd1ZXN0LCBub3cgdGhlIG1heGltdW0gdmFsdWUg
aXMgNCkKKworNS4gS25vd24gcG9zc2JpbGUgaXNzdWUgb24gc29tZSBwbGF0Zm9ybXMgd2l0aCBv
bGQgRmlybXdhcmUKKworSWYgbWVldCBzdHJhbmdlIGhvc3QgY3Jhc2hlcywgeW91IG1heSB0cnkg
dG8gc29sdmUgaXQgdGhyb3VnaCBlaXRoZXIgb2YgdGhlIGZvbGxvd2luZyBtZXRob2RzLgorKDEp
OiBVcGdyYWRlIHlvdXIgRmlybXdhcmUgdG8gdGhlIGxhdGVzdCBvbmUuCisKKygyKTogQXBwbHlp
bmcgdGhlIGJlbG93IHBhdGNoIHRvIGtlcm5lbCBzb3VyY2UuCitkaWZmIC0tZ2l0IGEvYXJjaC9p
YTY0L2tlcm5lbC9wYWwuUyBiL2FyY2gvaWE2NC9rZXJuZWwvcGFsLlMKK2luZGV4IDBiNTMzNDQu
LmYwMmIwZjcgMTAwNjQ0CistLS0gYS9hcmNoL2lhNjQva2VybmVsL3BhbC5TCisrKysgYi9hcmNo
L2lhNjQva2VybmVsL3BhbC5TCitAQCAtODQsNyArODQsOCBAQCBHTE9CQUxfRU5UUlkoaWE2NF9w
YWxfY2FsbF9zdGF0aWMpCisgCW1vdiBhci5wZnMgPSBsb2MxCisgCW1vdiBycCA9IGxvYzAKKyAJ
OzsKKy0Jc3Jsei5kCQkJCS8vIHNlcmFsaXplIHJlc3RvcmF0aW9uIG9mIHBzci5sCisrCXNybHou
aQkJCS8vIHNlcmFsaXplIHJlc3RvcmF0aW9uIG9mIHBzci5sCisrCTs7CisgCWJyLnJldC5zcHRr
Lm1hbnkgYjAKKyBFTkQoaWE2NF9wYWxfY2FsbF9zdGF0aWMpCisKKzYuIEJ1ZyByZXBvcnQ6CisJ
SWYgeW91IGZvdW5kIGFueSBpc3N1ZXMgd2hlbiB1c2Uga3ZtL2lhNjQsIFBsZWFzZSBwb3N0IHRo
ZSBidWcgaW5mbyB0byBrdm0taWE2NC1kZXZlbCBtYWlsaW5nIGxpc3QuCisJaHR0cHM6Ly9saXN0
cy5zb3VyY2Vmb3JnZS5uZXQvbGlzdHMvbGlzdGluZm8va3ZtLWlhNjQtZGV2ZWwvCisKK1RoYW5r
cyBmb3IgeW91ciBpbnRlcmVzdCEgTGV0J3Mgd29yayB0b2dldGhlciwgYW5kIG1ha2Uga3ZtL2lh
NjQgc3Ryb25nZXIgYW5kIHN0cm9uZ2VyISAKKworCisJCQkJCQkJCVpoYW5nIFhpYW50YW8gPHhp
YW50YW8uemhhbmdAaW50ZWwuY29tPgorCQkJCQkJCQkJCTIwMDguMS4yOAotLSAKMS41LjEKCg==

------_=_NextPart_001_01C863F4.57B96D7B--
