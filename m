From: "Zhu, Yi" <yi.zhu@intel.com>
Date: Thu, 18 Dec 2003 03:40:01 +0000
Subject: [BUG] Red Hat Enterprise Linux AS 3 GM + kernel 2.6.0-test11 halt
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C3C518.9D9A0C6F"
Message-Id: <marc-linux-ia64-107171885627499@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C3C518.9D9A0C6F
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable


Hi,

I installed Red Hat Enterprise Linux AS 3 GM on tiger4. Everything is
OK. Then I download the prestine 2.6.0-test11 kernel + ia64 patch=20
http://www.kernel.org/pub/linux/kernel/ports/ia64/v2.6/linux-2.6.0-test1
1-ia64-031126.diff.gz

Compiled successfully. But when the new kernel is booted, it halted at=20
"ACPI: Subsystem revision 20031002". The kernel is completely halted
without react any keyboard interupt. See my hand copy screen log in the
attachment. You can find my kernel .config in the attachment.

The same kernel (binary) can boot successfully on previous redhat AS
images and all the UL/SuSE images. I found there is a difference between
the new=20
redhat AS 3 GM and previous ones is there is an additional
/boot/efi/Intel Fireware/fpswa.efi file!

My FPSWA version is also 1.18 from the boot screen.=20

I read the Release Note and found below words
"Red Hat Enterprise Linux 3 for the Itanium 2 Architecture contains the
       fpswa.efi binary, which is an EFI (Extensible Firmware Interface)
       driver invoked by the operating system's kernel whenever the
processor
       issues FPSWA (Floating-Point Software Assistance) requests for
       floating-point operations that are not fully implemented in
hardware.
       The handler provides the result of the operation in these cases.
       Presently, Itanium processors issue FPSWA requests mainly when
very
       small numbers (denormalized, or tiny numbers) are consumed or
produced
       by floating-point instructions. To avoid the performance penalty
       caused by calls to the handler when tiny numbers are produced,
the
       flush-to-zero mode can be turned on, but at the cost of a
slightly
       less accurate computation.

       FPSWA is licensed, patented and copyrighted protected material by
       Intel or its supplier under the laws of the United states and
other
       countries and international treaty provisions. FPSWA is subject
to the
       applicable end user license agreement which can be accessed at
       http://www.redhat.com/licenses/."


The walk around way is as follow:

1. after the machine is booted, enter efi shell
2. remove fs0:\efi\"Intel Firmware"
3. save to NVRAM (*very important*)
4. exit efi shell and load your 2.6 kernel

Then you'll get the 2.6 kernel booted.

Everytime the machine is rebooted, I must redo step 3 above. Or the same
error will happen. :(

The default rh el kernel(Taroon 2.4.21-4.EL) boot ok without any
walkaround.

I believe this is a bug, either by EFI or by the 2.6 kernel.

Thanks,
-----------------------------------------------------------------
Opinions expressed are those of the author and do not represent Intel
Corp.

- Zhu Yi (Chuyee)

GnuPG v1.0.6 (GNU/Linux) http://cn.geocities.com/chewie_chuyee/gpg.txt
or $ gpg --keyserver wwwkeys.pgp.net --recv-keys 71C34820 1024D/71C34820
C939 2B0B FBCE 1D51 109A  55E5 8650 DB90 71C3 4820=20

------_=_NextPart_001_01C3C518.9D9A0C6F
Content-Type: text/plain;
	name="tiger4.txt"
Content-Transfer-Encoding: base64
Content-Description: tiger4.txt
Content-Disposition: attachment;
	filename="tiger4.txt"

TWVtb3J5OiA5NTUzOTJrLzk2NTEzNmsgYXZhaWxhYmxlICg4MzUxayBjb2RlLCAyMTAwOGsgcmVz
ZXJ2ZWQsIDI3MzlrIGRhdGEsIDI4ODEgaW5pdCkKTGVhdmluZyBNY0tpbmxleSBFcnJhdGEgOSB3
b3JrYXJvdW5kIGVuYWJsZWQKQ2FsaWJyYXRpbmcgZGVsYXkgbG9vcC4uLiAxMzQyLjQwIEJvZ29N
SVBTCkRlbnRyeSBjYWNoZSBoYXNoIHRhYmxlIGVudHJpZXM6IDY1NTM2IChvcmRlcjogNSwgNTI0
Mjg4IGJ5dGVzKQpJbm9kZS1jYWNoZSBoYXNoIHRhYmxlIGVudHJpZXM6IDY1NTM2IChvcmRlcjog
NSwgNTI0Mjg4IGJ5dGVzKQpNb3VudC1jYWNoZSBoYXNoIHRhYmxlIGVudHJpZXM6IDEwMjQgKG9y
ZGVyOiAwLCAxNjM4NCBieXRlcykKUE9TSVggY29uZm9ybWFuY2UgdGVzdGluZyBieSBVTklGSVgK
Qm9vdCBwcm9jZXNzb3IgaWQgMHgwLzB4YzYxOAp0YXNrIG1pZ3JhdGlvbiBjYWNoZSBkZWNheSB0
aW1lb3V0OiAxMCBtc2Vjcy4KU3RhcnRpbmcgbWlncmF0aW9uIHRocmVhZCBmb3IgY3B1IDAKQnJp
bmdpbmcgdXAgMQpQcm9jZXNzb3IgNDk2ODgvMSBpcyBzcGlubmluZyB1cC4uLgpQcm9jZXNzb3Ig
MHgxLzB4YzIxOCBpcyBzdHVjay4KQnJpbmdpbmcgdXAgMgpQcm9jZXNzb3IgNTAyMDAvMiBpcyBz
cGlubmluZyB1cC4uLgpQcm9jZXNzb3IgMHgyLzB4YzQxOCBpcyBzdHVjay4KQnJpbmdpbmcgdXAg
MwpQcm9jZXNzb3IgNDkxNzYvMyBpcyBzcGlubmluZyB1cC4uLgpQcm9jZXNzb3IgMHgzLzB4YzAx
OCBpcyBzdHVjay4KQ1BVUyBkb25lIDMyClRvdGFsIG9mIDEgcHJvY2Vzc29ycyBhY3RpdmF0ZWQg
KDEzNDIuNDAgQm9nb01JUFMpLgpORVQ6IFJlZ2lzdGVyZWQgcHJvdG9jb2wgZmFtaWx5IDE2CkFD
UEk6IFN1YnN5c3RlbSByZXZpc2lvbiAyMDAzMTAwMgo=

------_=_NextPart_001_01C3C518.9D9A0C6F--
