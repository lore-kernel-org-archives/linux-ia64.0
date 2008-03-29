From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Sat, 29 Mar 2008 02:38:51 +0000
Subject: [17/17][PATCH] kvm/ia64: How to boot up guests on kvm/ia64 V7
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDCFF7F67@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C89146.0649AF63"
List-Id: <linux-ia64.vger.kernel.org>
References: <42DFA526FC41B1429CE7279EF83C6BDCFF7EEF@pdsmsx415.ccr.corp.intel.com>
In-Reply-To: <42DFA526FC41B1429CE7279EF83C6BDCFF7EEF@pdsmsx415.ccr.corp.intel.com>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C89146.0649AF63
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

From 454e8a4473ed13ce313b2ba3b654feb926a891b7 Mon Sep 17 00:00:00 2001
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

------_=_NextPart_001_01C89146.0649AF63
Content-Type: application/octet-stream;
	name="0017-kvm-ia64-How-to-boot-up-guests-on-kvm-ia64.patch"
Content-Transfer-Encoding: base64
Content-Description: 0017-kvm-ia64-How-to-boot-up-guests-on-kvm-ia64.patch
Content-Disposition: attachment;
	filename="0017-kvm-ia64-How-to-boot-up-guests-on-kvm-ia64.patch"

RnJvbSA0NTRlOGE0NDczZWQxM2NlMzEzYjJiYTNiNjU0ZmViOTI2YTg5MWI3IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBYaWFudGFvIFpoYW5nIDx4aWFudGFvLnpoYW5nQGludGVsLmNv
bT4KRGF0ZTogV2VkLCAxMiBNYXIgMjAwOCAxMzo1NzozMyArMDgwMApTdWJqZWN0OiBbUEFUQ0hd
IGt2bS9pYTY0OiBIb3cgdG8gYm9vdCB1cCBndWVzdHMgb24ga3ZtL2lhNjQKClNpZ25lZC1vZmYt
Ynk6IFhpYW50YW8gWmhhbmcgPHhpYW50YW8uemhhbmdAaW50ZWwuY29tPgotLS0KIERvY3VtZW50
YXRpb24vaWE2NC9rdm0taG93dG8udHh0IHwgICA3NCArKysrKysrKysrKysrKysrKysrKysrKysr
KysrKysrKysrKysrKwogMSBmaWxlcyBjaGFuZ2VkLCA3NCBpbnNlcnRpb25zKCspLCAwIGRlbGV0
aW9ucygtKQogY3JlYXRlIG1vZGUgMTAwNjQ0IERvY3VtZW50YXRpb24vaWE2NC9rdm0taG93dG8u
dHh0CgpkaWZmIC0tZ2l0IGEvRG9jdW1lbnRhdGlvbi9pYTY0L2t2bS1ob3d0by50eHQgYi9Eb2N1
bWVudGF0aW9uL2lhNjQva3ZtLWhvd3RvLnR4dApuZXcgZmlsZSBtb2RlIDEwMDY0NAppbmRleCAw
MDAwMDAwLi41YTgwNDljCi0tLSAvZGV2L251bGwKKysrIGIvRG9jdW1lbnRhdGlvbi9pYTY0L2t2
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
IHNvdXJjZSBjb2RlLiBQbGVhc2UgZG93bmxvYWQgdGhlIHNvdXJjZSBmcm9tCisJCWhnIGNsb25l
IGh0dHA6Ly94ZW5iaXRzLnhlbnNvdXJjZS5jb20vZXh0L2VmaS12ZmlybXdhcmUuaGcKKwkJVXNl
IHRoZSBHdWlkZSBvZiB0aGUgc291cmNlIHRvIGJ1aWxkIG9wZW4gR3Vlc3QgRmlybXdhcmUuCisJ
KDMpIFJlbmFtZSBpdCB0byBGbGFzaC5mZCwgYW5kIGNvcHkgaXQgdG8gL3Vzci9sb2NhbC9zaGFy
ZS9xZW11CitOb3RlOiBGb3Igc3RlcCAzLCBrdm0gdXNlIHRoZSBndWVzdCBmaXJtd2FyZSB3aGlj
aCBjb21wbGllcyB3aXRoIHRoZSBvbmUgWGVuIHVzZXMuCisKKzQuIEJvb3QgdXAgTGludXggb3Ig
V2luZG93cyBndWVzdHM6CisJNC4xIENyZWF0ZSBvciBpbnN0YWxsIGEgaW1hZ2UgZm9yIGd1ZXN0
IGJvb3QuIElmIHlvdSBoYXZlIHhlbiBleHBlcmllbmNlLCBpdCBzaG91bGQgYmUgZWFzeS4KKwor
CTQuMiBCb290IHVwIGd1ZXN0cyB1c2UgdGhlIGZvbGxvd2luZyBjb21tYW5kLgorCQkvdXNyL2xv
Y2FsL2Jpbi9xZW11LXN5c3RlbS1pYTY0IC1zbXAgeHggLW0gNTEyIC1oZGEgJHlvdXJfaW1hZ2UK
KwkJKHh4IGlzIHRoZSBudW1iZXIgb2YgdmlydHVhbCBwcm9jZXNzb3JzIGZvciB0aGUgZ3Vlc3Qs
IG5vdyB0aGUgbWF4aW11bSB2YWx1ZSBpcyA0KQorCis1LiBLbm93biBwb3NzaWJpbGUgaXNzdWUg
b24gc29tZSBwbGF0Zm9ybXMgd2l0aCBvbGQgRmlybXdhcmUKKworSWYgbWVldCBzdHJhbmdlIGhv
c3QgY3Jhc2hlcywgeW91IG1heSB0cnkgdG8gc29sdmUgaXQgdGhyb3VnaCBlaXRoZXIgb2YgdGhl
IGZvbGxvd2luZyBtZXRob2RzLgorKDEpOiBVcGdyYWRlIHlvdXIgRmlybXdhcmUgdG8gdGhlIGxh
dGVzdCBvbmUuCisKKygyKTogQXBwbHlpbmcgdGhlIGJlbG93IHBhdGNoIHRvIGtlcm5lbCBzb3Vy
Y2UuCitkaWZmIC0tZ2l0IGEvYXJjaC9pYTY0L2tlcm5lbC9wYWwuUyBiL2FyY2gvaWE2NC9rZXJu
ZWwvcGFsLlMKK2luZGV4IDBiNTMzNDQuLmYwMmIwZjcgMTAwNjQ0CistLS0gYS9hcmNoL2lhNjQv
a2VybmVsL3BhbC5TCisrKysgYi9hcmNoL2lhNjQva2VybmVsL3BhbC5TCitAQCAtODQsNyArODQs
OCBAQCBHTE9CQUxfRU5UUlkoaWE2NF9wYWxfY2FsbF9zdGF0aWMpCisgCW1vdiBhci5wZnMgPSBs
b2MxCisgCW1vdiBycCA9IGxvYzAKKyAJOzsKKy0Jc3Jsei5kCQkJCS8vIHNlcmlhbGl6ZSByZXN0
b3JhdGlvbiBvZiBwc3IubAorKwlzcmx6LmkJCQkvLyBzZXJpYWxpemUgcmVzdG9yYXRpb24gb2Yg
cHNyLmwKKysJOzsKKyAJYnIucmV0LnNwdGsubWFueSBiMAorIEVORChpYTY0X3BhbF9jYWxsX3N0
YXRpYykKKworNi4gQnVnIHJlcG9ydDoKKwlJZiB5b3UgZm91bmQgYW55IGlzc3VlcyB3aGVuIHVz
ZSBrdm0vaWE2NCwgUGxlYXNlIHBvc3QgdGhlIGJ1ZyBpbmZvIHRvIGt2bS1pYTY0LWRldmVsIG1h
aWxpbmcgbGlzdC4KKwlodHRwczovL2xpc3RzLnNvdXJjZWZvcmdlLm5ldC9saXN0cy9saXN0aW5m
by9rdm0taWE2NC1kZXZlbC8KKworVGhhbmtzIGZvciB5b3VyIGludGVyZXN0ISBMZXQncyB3b3Jr
IHRvZ2V0aGVyLCBhbmQgbWFrZSBrdm0vaWE2NCBzdHJvbmdlciBhbmQgc3Ryb25nZXIhIAorCisK
KwkJCQkJCQkJWGlhbnRhbyBaaGFuZyA8eGlhbnRhby56aGFuZ0BpbnRlbC5jb20+CisJCQkJCQkJ
CQkJCTIwMDguMy4xMAotLSAKMS41LjIKCg==

------_=_NextPart_001_01C89146.0649AF63--
