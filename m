From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 28 Aug 2003 16:04:13 +0000
Subject: [PATCH 2.4 and 2.6] trim.bottom trims the wrong entry
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C36D7E.06862A74"
Message-Id: <marc-linux-ia64-106208671402725@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C36D7E.06862A74
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

This was a fun one to track down.  I was trying to provide
a fake SRAT table so that I could start working on some more
ccNUMA issues on a non-NUMA tiger box, but my kernel kept dying
while running scripts out of /etc/init.d/*

I found I was getting an MCA while executing an lfetch.excl in
clear_page_tables(), the address that was being fetched was
0xe0000000000a00e8, which is non-cacheable VGA memory on Tiger.

Root cause was the "trim" code in efi_memmap_walk() had failed
to trim away all the blocks of memory in the bottom granule when
it had seen the memory hole there, so the kernel had managed to
allocate a page at 0x9c000 as a page table, and when the process
using it ended, the cleanup code prefetched off the end of the
page, and into the VGA memory, causing an MCA.

The problem is that efi_memmap_walk() repeatedly trims the same
entry, instead of trimming each of the entries in the granule.

-Tony

------_=_NextPart_001_01C36D7E.06862A74
Content-Type: application/octet-stream;
	name="trim.patch"
Content-Transfer-Encoding: base64
Content-Description: trim.patch
Content-Disposition: attachment;
	filename="trim.patch"

ZGlmZiAtcnUgYS9hcmNoL2lhNjQva2VybmVsL2VmaS5jIGIvYXJjaC9pYTY0L2tlcm5lbC9lZmku
YwotLS0gYS9hcmNoL2lhNjQva2VybmVsL2VmaS5jCVdlZCBBdWcgMjcgMTU6NDk6MjcgMjAwMwor
KysgYi9hcmNoL2lhNjQva2VybmVsL2VmaS5jCVdlZCBBdWcgMjcgMTY6NDc6MjcgMjAwMwpAQCAt
MzI0LDcgKzMyNCw3IEBACiAJCQkJY2hlY2tfbWQgPSBxOwogCiAJCQkJaWYgKGNoZWNrX21kLT5h
dHRyaWJ1dGUgJiBFRklfTUVNT1JZX1dCKQotCQkJCQl0cmltX2JvdHRvbShtZCwgZ3JhbnVsZV9h
ZGRyKTsKKwkJCQkJdHJpbV9ib3R0b20oY2hlY2tfbWQsIGdyYW51bGVfYWRkcik7CiAKIAkJCQlp
ZiAoY2hlY2tfbWQtPnBoeXNfYWRkciA8IGdyYW51bGVfYWRkcikKIAkJCQkJY29udGludWU7Cg==

------_=_NextPart_001_01C36D7E.06862A74--
