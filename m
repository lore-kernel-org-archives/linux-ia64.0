From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 15 Jul 2004 19:11:07 +0000
Subject: RE: free bootmem feedback patch
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F01A5DC54@scsmsx401.amr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C46A9F.7C96B803"
List-Id: <linux-ia64.vger.kernel.org>
References: <40F46962.4090604@sgi.com>
In-Reply-To: <40F46962.4090604@sgi.com>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C46A9F.7C96B803
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

William Irwin wrote:
>I'd even go so far as to suggest scanning the bitmap until the
>maximally sized higher-order page to free at the cursor (determined
>by cursor alignment and the first bit indicating a reserved page or
>otherwise MAX_ORDER bits out from the cursor) is found.

Attached is my version that just frees pages in O(log2(BITS_PER_LONG))
pieces ... because I'm too lazy to figure out all the boundary
conditions to implement wli's excellent suggestion.

On my 2G machine, this reduced the time to free all the bootmem
from 41ms to 18.1ms ... so it should shave some minutes off the
monster SGI box that started this thread, but perhaps not enough
to avoid the "looks like the system is hung" problem as you will
still be looking at a couple of minutes :-(  Since I only got a
55% reduction, rather than a factor of 64 I expect that modifying
to look an larger order pages may have diminishing returns.

Notes and Caveats:
1) Is there a define someplace for log2(BITS_PER_LONG)?  I couldn't
find one, which is why I calculate the "order" in this patch.

2) On ia64 it looks like the pages and the bitmap are nicely aligned
so that a longword in node_bootmem_map[] corresponds to an order 6
page with the right physical alignment.  This may not be true on other
architectures, and mm/bootmem.c is generic code.  Before this patch
can go into the base, someone would have to check all the other
architectures (some of which might not care to change ... if they
only support 4G or less, then the benefits of saving a few milliseconds
during boot may not inspire them to mess with the boot code).  For
this reason I'm not adding a "Signed-off-by" to this patch because
I don't want the flack for breaking other architectures ... but by
all means take this patch and try it out.

I did also play with adding a "prefetchw(page + N)" to the original
loop.  With N>=3D6 the saving is about 5% for me.  SGI might need a
bigger N, and might see more savings, since most of the accesses
here are to remote nodes.  I didn't try this in my modified patch
(the gains may be smaller as we don't do as much work in between
touching each page).

-Tony

------_=_NextPart_001_01C46A9F.7C96B803
Content-Type: application/octet-stream;
	name="bootmem.patch"
Content-Transfer-Encoding: base64
Content-Description: bootmem.patch
Content-Disposition: attachment;
	filename="bootmem.patch"

ZGlmZiAtcnUgbGludXgtMi42LjgtcmMxLW9yaWcvbW0vYm9vdG1lbS5jIGxpbnV4LTIuNi44LXJj
MS9tbS9ib290bWVtLmMKLS0tIGxpbnV4LTIuNi44LXJjMS1vcmlnL21tL2Jvb3RtZW0uYwkyMDA0
LTA3LTExIDEwOjM0OjE5LjAwMDAwMDAwMCAtMDcwMAorKysgbGludXgtMi42LjgtcmMxL21tL2Jv
b3RtZW0uYwkyMDA0LTA3LTE1IDExOjIyOjMzLjQ2NDc5NDEwOSAtMDcwMApAQCAtMjU5LDkgKzI1
OSwxMiBAQAogCXVuc2lnbmVkIGxvbmcgaSwgY291bnQsIHRvdGFsID0gMDsKIAl1bnNpZ25lZCBs
b25nIGlkeDsKIAl1bnNpZ25lZCBsb25nICptYXA7IAorCWludCBvcmRlcjsKIAogCUJVR19PTigh
YmRhdGEtPm5vZGVfYm9vdG1lbV9tYXApOwogCisJZm9yIChvcmRlciA9IDA7ICgxIDw8IG9yZGVy
KSA8IEJJVFNfUEVSX0xPTkc7IG9yZGVyKyspCisJCTsKIAljb3VudCA9IDA7CiAJLyogZmlyc3Qg
ZXh0YW50IHBhZ2Ugb2YgdGhlIG5vZGUgKi8KIAlwYWdlID0gdmlydF90b19wYWdlKHBoeXNfdG9f
dmlydChiZGF0YS0+bm9kZV9ib290X3N0YXJ0KSk7CkBAIC0yNjksNyArMjcyLDIwIEBACiAJbWFw
ID0gYmRhdGEtPm5vZGVfYm9vdG1lbV9tYXA7CiAJZm9yIChpID0gMDsgaSA8IGlkeDsgKSB7CiAJ
CXVuc2lnbmVkIGxvbmcgdiA9IH5tYXBbaSAvIEJJVFNfUEVSX0xPTkddOwotCQlpZiAodikgewor
CQlpZiAodiA9PSB+MFVMKSB7CisJCQlpbnQgajsKKworCQkJY291bnQgKz0gQklUU19QRVJfTE9O
RzsKKwkJCUNsZWFyUGFnZVJlc2VydmVkKHBhZ2UpOworCQkJc2V0X3BhZ2VfY291bnQocGFnZSwg
MSk7CisJCQlmb3IgKGogPSAxOyBqIDwgQklUU19QRVJfTE9ORzsgaisrKSB7CisJCQkJQ2xlYXJQ
YWdlUmVzZXJ2ZWQocGFnZSArIGopOworCQkJCXNldF9wYWdlX2NvdW50KHBhZ2UgKyBqLCAwKTsK
KwkJCX0KKwkJCV9fZnJlZV9wYWdlcyhwYWdlLCBvcmRlcik7CisJCQlpICs9IEJJVFNfUEVSX0xP
Tkc7CisJCQlwYWdlICs9IEJJVFNfUEVSX0xPTkc7CisJCX0gZWxzZSBpZiAodikgewogCQkJdW5z
aWduZWQgbG9uZyBtOwogCQkJZm9yIChtID0gMTsgbSAmJiBpIDwgaWR4OyBtPDw9MSwgcGFnZSsr
LCBpKyspIHsKIAkJCQlpZiAodiAmIG0pIHsK

------_=_NextPart_001_01C46A9F.7C96B803--
