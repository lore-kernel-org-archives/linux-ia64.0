From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Fri, 28 Mar 2008 09:58:07 +0000
Subject: [17/17][PATCH] kvm/ia64: How to boot up guests on kvm/ia64
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDCFF7EEF@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C890BA.396774EB"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C890BA.396774EB
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

From 517a89fd248193f6a7049832e2c1b811afe98f96 Mon Sep 17 00:00:00 2001
From: Xiantao Zhang <xiantao.zhang@intel.com>
Date: Wed, 12 Mar 2008 13:57:33 +0800
Subject: [PATCH] kvm/ia64: How to boot up guests on kvm/ia64

Signed-off-by: Xiantao Zhang <xiantao.zhang@intel.com>
---
 Documentation/ia64/kvm-howto.txt |   74
++++++++++++++++++++++++++++++++++++++
 1 files changed, 74 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/ia64/kvm-howto.txt

diff --git a/Documentation/ia64/kvm-howto.txt
b/Documentation/ia64/kvm-howto.txt
new file mode 100644
index 0000000..ad853b9
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
+								Xiantao
Zhang <xiantao.zhang@intel.com>
+
2008.3.10
--=20
1.5.2

------_=_NextPart_001_01C890BA.396774EB
Content-Type: application/octet-stream;
	name="0017-kvm-ia64-How-to-boot-up-guests-on-kvm-ia64.patch"
Content-Transfer-Encoding: base64
Content-Description: 0017-kvm-ia64-How-to-boot-up-guests-on-kvm-ia64.patch
Content-Disposition: attachment;
	filename="0017-kvm-ia64-How-to-boot-up-guests-on-kvm-ia64.patch"

RnJvbSA1MTdhODlmZDI0ODE5M2Y2YTcwNDk4MzJlMmMxYjgxMWFmZTk4Zjk2IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBYaWFudGFvIFpoYW5nIDx4aWFudGFvLnpoYW5nQGludGVsLmNv
bT4KRGF0ZTogV2VkLCAxMiBNYXIgMjAwOCAxMzo1NzozMyArMDgwMApTdWJqZWN0OiBbUEFUQ0hd
IGt2bS9pYTY0OiBIb3cgdG8gYm9vdCB1cCBndWVzdHMgb24ga3ZtL2lhNjQKClNpZ25lZC1vZmYt
Ynk6IFhpYW50YW8gWmhhbmcgPHhpYW50YW8uemhhbmdAaW50ZWwuY29tPgotLS0KIERvY3VtZW50
YXRpb24vaWE2NC9rdm0taG93dG8udHh0IHwgICA3NCArKysrKysrKysrKysrKysrKysrKysrKysr
KysrKysrKysrKysrKwogMSBmaWxlcyBjaGFuZ2VkLCA3NCBpbnNlcnRpb25zKCspLCAwIGRlbGV0
aW9ucygtKQogY3JlYXRlIG1vZGUgMTAwNjQ0IERvY3VtZW50YXRpb24vaWE2NC9rdm0taG93dG8u
dHh0CgpkaWZmIC0tZ2l0IGEvRG9jdW1lbnRhdGlvbi9pYTY0L2t2bS1ob3d0by50eHQgYi9Eb2N1
bWVudGF0aW9uL2lhNjQva3ZtLWhvd3RvLnR4dApuZXcgZmlsZSBtb2RlIDEwMDY0NAppbmRleCAw
MDAwMDAwLi5hZDg1M2I5Ci0tLSAvZGV2L251bGwKKysrIGIvRG9jdW1lbnRhdGlvbi9pYTY0L2t2
bS1ob3d0by50eHQKQEAgLTAsMCArMSw3NCBAQAorCQkJCUd1aWRlOiBIb3cgdG8gYm9vdCB1cCBn
dWVzdHMgb24ga3ZtL2lhNjQKKworMS4gR2V0IHRoZSBrdm0gc291cmNlIGZyb20gZ2l0Lmtlcm5l
bC5vcmcuCisJVXNlcnNwYWNlIHNvdXJjZToKKwkJZ2l0IGNsb25lIGdpdDovL2dpdC5rZXJuZWwu
b3JnL3B1Yi9zY20vdmlydC9rdm0va3ZtLXVzZXJzcGFjZS5naXQKKwlLZXJuZWwgU291cmNlOgor
CQlnaXQgY2xvbmUgZ2l0Oi8vZ2l0Lmtlcm5lbC5vcmcvcHViL3NjbS9saW51eC9rZXJuZWwvZ2l0
L3hpYW50YW8va3ZtLWlhNjQuZ2l0CisKKzIuIENvbXBpbGUgdGhlIHNvdXJjZSBjb2RlLgorCTIu
MSBDb21waWxlIHVzZXJzcGFjZSBjb2RlOgorCQkoMSljZCAuL2t2bS11c2Vyc3BhY2UKKwkJKDIp
Li9jb25maWd1cmUKKwkJKDMpY2Qga2VybmVsCisJCSg0KW1ha2Ugc3luYyBMSU5VWD0gJGtlcm5l
bF9kaXIgKGtlcm5lbF9kaXIgaXMgdGhlIGRpcmVjdG9yeSBvZiBrZXJuZWwgc291cmNlLikKKwkJ
KDUpY2QgLi4KKwkJKDYpbWFrZSBxZW11CisJCSg3KWNkIHFlbXU7IG1ha2UgaW5zdGFsbAorCisJ
Mi4yIENvbXBpbGUga2VybmVsIHNvdXJjZSBjb2RlOgorCQkoMSkgY2QgLi8ka2VybmVsX2Rpcgor
CQkoMikgTWFrZSBtZW51Y29uZmlnIAorCQkoMykgRW50ZXIgaW50byB2aXJ0dWFsaXphdGlvbiBv
cHRpb24sIGFuZCBjaG9vc2Uga3ZtLgorCQkoNCkgbWFrZSAKKwkJKDUpIE9uY2UgKDQpIGRvbmUs
IG1ha2UgbW9kdWxlc19pbnN0YWxsCisJCSg2KSBNYWtlIGluaXRyZCwgYW5kIHVzZSBuZXcga2Vy
bmVsIHRvIHJlYm9vdCB1cCBob3N0IG1hY2hpbmUuCisJCSg3KSBPbmNlICg2KSBkb25lLCBjZCAk
a2VybmVsX2Rpci9hcmNoL2lhNjQva3ZtCisJCSg4KSBpbnNtb2Qga3ZtLmtvOyBpbnNtb2Qga3Zt
LWludGVsLmtvCisKK05vdGU6IEZvciBzdGVwIDIsIHBsZWFzZSBtYWtlIHN1cmUgdGhhdCBob3N0
IHBhZ2Ugc2l6ZSA9PSBUQVJHRVRfUEFHRV9TSVpFIG9mIHFlbXUsIG90aGVyd2lzZSwgbWF5IGZh
aWwuCisKKzMuIEdldCBHdWVzdCBGaXJtd2FyZSBuYW1lZCBhcyBGbGFzaC5mZCwgYW5kIHB1dCBp
dCB1bmRlciByaWdodCBwbGFjZToKKwkoMSkgSWYgeW91IGhhdmUgdGhlIGd1ZXN0IGZpcm13YXJl
IChiaW5hcnkpcmVsZWFzZWQgYnkgSW50ZWwgQ29ycCBmb3IgWGVuLCB5b3UgY2FuIHVzZSBpdCBk
aXJlY3RseS4KKwkoMikgSWYgeW91IHdhbnQgdG8gYnVpbGQgYSBndWVzdCBmaXJtd2FyZSBmb3Jt
IHNvdWNlIGNvZGUuIFBsZWFzZSBkb3dubG9hZCB0aGUgc291cmNlIGZyb20KKwkJaGcgY2xvbmUg
aHR0cDovL3hlbmJpdHMueGVuc291cmNlLmNvbS9leHQvZWZpLXZmaXJtd2FyZS5oZworCQlVc2Ug
dGhlIEd1aWRlIG9mIHRoZSBzb3VyY2UgdG8gYnVpbGQgb3BlbiBHdWVzdCBGaXJtd2FyZS4KKwko
MykgUmVuYW1lIGl0IHRvIEZsYXNoLmZkLCBhbmQgY29weSBpdCB0byAvdXNyL2xvY2FsL3NoYXJl
L3FlbXUKK05vdGU6IEZvciBzdGVwIDMsIGt2bSB1c2UgdGhlIGd1ZXN0IGZpcm13YXJlIHdoaWNo
IGNvbXBsaWVzIHdpdGggdGhlIG9uZSBYZW4gdXNlcy4KKworNC4gQm9vdCB1cCBMaW51eCBvciBX
aW5kb3dzIGd1ZXN0czoKKwk0LjEgQ3JlYXRlIG9yIGluc3RhbGwgYSBpbWFnZSBmb3IgZ3Vlc3Qg
Ym9vdC4gSWYgeW91IGhhdmUgeGVuIGV4cGVyaWVuY2UsIGl0IHNob3VsZCBiZSBlYXN5LgorCisJ
NC4yIEJvb3QgdXAgZ3Vlc3RzIHVzZSB0aGUgZm9sbG93aW5nIGNvbW1hbmQuCisJCS91c3IvbG9j
YWwvYmluL3FlbXUtc3lzdGVtLWlhNjQgLXNtcCB4eCAtbSA1MTIgLWhkYSAkeW91cl9pbWFnZQor
CQkoeHggaXMgdGhlIG51bWJlciBvZiB2aXJ0dWFsIHByb2Nlc3NvcnMgZm9yIHRoZSBndWVzdCwg
bm93IHRoZSBtYXhpbXVtIHZhbHVlIGlzIDQpCisKKzUuIEtub3duIHBvc3NiaWxlIGlzc3VlIG9u
IHNvbWUgcGxhdGZvcm1zIHdpdGggb2xkIEZpcm13YXJlCisKK0lmIG1lZXQgc3RyYW5nZSBob3N0
IGNyYXNoZXMsIHlvdSBtYXkgdHJ5IHRvIHNvbHZlIGl0IHRocm91Z2ggZWl0aGVyIG9mIHRoZSBm
b2xsb3dpbmcgbWV0aG9kcy4KKygxKTogVXBncmFkZSB5b3VyIEZpcm13YXJlIHRvIHRoZSBsYXRl
c3Qgb25lLgorCisoMik6IEFwcGx5aW5nIHRoZSBiZWxvdyBwYXRjaCB0byBrZXJuZWwgc291cmNl
LgorZGlmZiAtLWdpdCBhL2FyY2gvaWE2NC9rZXJuZWwvcGFsLlMgYi9hcmNoL2lhNjQva2VybmVs
L3BhbC5TCitpbmRleCAwYjUzMzQ0Li5mMDJiMGY3IDEwMDY0NAorLS0tIGEvYXJjaC9pYTY0L2tl
cm5lbC9wYWwuUworKysrIGIvYXJjaC9pYTY0L2tlcm5lbC9wYWwuUworQEAgLTg0LDcgKzg0LDgg
QEAgR0xPQkFMX0VOVFJZKGlhNjRfcGFsX2NhbGxfc3RhdGljKQorIAltb3YgYXIucGZzID0gbG9j
MQorIAltb3YgcnAgPSBsb2MwCisgCTs7CistCXNybHouZAkJCQkvLyBzZXJhbGl6ZSByZXN0b3Jh
dGlvbiBvZiBwc3IubAorKwlzcmx6LmkJCQkvLyBzZXJhbGl6ZSByZXN0b3JhdGlvbiBvZiBwc3Iu
bAorKwk7OworIAlici5yZXQuc3B0ay5tYW55IGIwCisgRU5EKGlhNjRfcGFsX2NhbGxfc3RhdGlj
KQorCis2LiBCdWcgcmVwb3J0OgorCUlmIHlvdSBmb3VuZCBhbnkgaXNzdWVzIHdoZW4gdXNlIGt2
bS9pYTY0LCBQbGVhc2UgcG9zdCB0aGUgYnVnIGluZm8gdG8ga3ZtLWlhNjQtZGV2ZWwgbWFpbGlu
ZyBsaXN0LgorCWh0dHBzOi8vbGlzdHMuc291cmNlZm9yZ2UubmV0L2xpc3RzL2xpc3RpbmZvL2t2
bS1pYTY0LWRldmVsLworCitUaGFua3MgZm9yIHlvdXIgaW50ZXJlc3QhIExldCdzIHdvcmsgdG9n
ZXRoZXIsIGFuZCBtYWtlIGt2bS9pYTY0IHN0cm9uZ2VyIGFuZCBzdHJvbmdlciEgCisKKworCQkJ
CQkJCQlYaWFudGFvIFpoYW5nIDx4aWFudGFvLnpoYW5nQGludGVsLmNvbT4KKwkJCQkJCQkJCQkJ
MjAwOC4zLjEwCi0tIAoxLjUuMgoK

------_=_NextPart_001_01C890BA.396774EB--
