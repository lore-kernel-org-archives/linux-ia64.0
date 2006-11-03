From: "Zou, Nanhai" <nanhai.zou@intel.com>
Date: Fri, 03 Nov 2006 00:28:31 +0000
Subject: RE: 05e0caad3b7bd0d0fbeff980bca22f186241a501 breaks ia64 kdump
Message-Id: <10EA09EFD8728347A513008B6B0DA77A086B0E@pdsmsx411.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C6FEDE.FDA60C3D"
List-Id: <linux-ia64.vger.kernel.org>
References: <20061026075951.GA30910@verge.net.au>
In-Reply-To: <20061026075951.GA30910@verge.net.au>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C6FEDE.FDA60C3D
Content-Type: text/plain;
	charset="gb2312"
Content-Transfer-Encoding: quoted-printable

Hi,
	This patch should fix the issue.

Thanks
Zou Nan hai

> -----Original Message-----
> From: Mel Gorman [mailto:mel@csn.ul.ie]
> Sent: 2006=C4=EA11=D4=C23=C8=D5 0:27
> To: Horms
> Cc: Andy Whitcroft; Zou, Nanhai; linux-ia64@vger.kernel.org; Bob =
Picco; Andrew
> Morton; Dave Hansen; Andi Kleen; Benjamin Herrenschmidt; Paul =
Mackerras; Keith
> Mannthey; Luck, Tony; KAMEZAWA Hiroyuki; Yasunori Goto; Khalid Aziz
> Subject: Re: 05e0caad3b7bd0d0fbeff980bca22f186241a501 breaks ia64 =
kdump
>=20
> On Thu, 2 Nov 2006, Horms wrote:
>=20
> > On Wed, Nov 01, 2006 at 09:38:38AM +0000, Mel Gorman wrote:
> >>
> >> Plan C
> >>
> >> Call add_active_ranges() for the the PFN ranges initmem reside in.
> >> Look at free_initmem() to see how to get the virtual address of the
> >> range is found and make the appropriate conversion. A variation is =
to
> >> call add_active_ranges() for the PFN range the whole kernel resides =
in
> >> if you have that information for the crash kernel.
> >
> > I've made a version of this approach that seems to work.
> > I had to update add_active_range so that it merges
> > ranges that are not overlapping, but do create a continous range.
> > Is this a correct thing to do?
> >
>=20
> It's a bit unlikely it's the correct fix. As you can see, the
> add_active_range() is already able to merge contiguous ranges. If the
> calls imply there is a one page hole, then there is a one page hole. =
If
> the caller is wrong and there isn't a one-page hole, then fix the =
caller
> walking the map. Power for example currently merges large numbers of
> adjacent regions that are registered separetly.
>=20
>=20
> > --
> > Horms
> >  H: http://www.vergenet.net/~horms/
> >  W: http://www.valinux.co.jp/en/
> >
> > Index: linux-2.6/mm/page_alloc.c
> > =
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > --- linux-2.6.orig/mm/page_alloc.c	2006-11-02 16:17:17.000000000 =
+0900
> > +++ linux-2.6/mm/page_alloc.c	2006-11-02 16:17:22.000000000 +0900
> > @@ -2407,7 +2407,7 @@
> > 			return;
> >
> > 		/* Merge forward if suitable */
> > -		if (start_pfn <=3D early_node_map[i].end_pfn &&
> > +		if (start_pfn <=3D early_node_map[i].end_pfn + 1 &&
> > 				end_pfn > early_node_map[i].end_pfn) {
> > 			early_node_map[i].end_pfn =3D end_pfn;
> > 			return;
> > @@ -2415,7 +2415,7 @@
> >
> > 		/* Merge backward if suitable */
> > 		if (start_pfn < early_node_map[i].end_pfn &&
> > -				end_pfn >=3D early_node_map[i].start_pfn) {
> > +				end_pfn + 1 >=3D early_node_map[i].start_pfn) {
> > 			early_node_map[i].start_pfn =3D start_pfn;
> > 			return;
> > 		}
> > Index: linux-2.6/arch/ia64/mm/discontig.c
> > =
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > --- linux-2.6.orig/arch/ia64/mm/discontig.c	2006-11-02
> 16:17:59.000000000 +0900
> > +++ linux-2.6/arch/ia64/mm/discontig.c	2006-11-02 16:18:03.000000000
> +0900
> > @@ -689,6 +689,8 @@
> > 	arch_sparse_init();
> >
> > 	efi_memmap_walk(filter_rsvd_memory, count_node_pages);
> > +	add_active_range(0, ia64_tpa(_text) >> PAGE_SHIFT,
> > +	                 (ia64_tpa(_end) -1 ) >> PAGE_SHIFT);
> >
> > #ifdef CONFIG_VIRTUAL_MEM_MAP
> > 	vmalloc_end -=3D PAGE_ALIGN(ALIGN(max_low_pfn, MAX_ORDER_NR_PAGES) =
*
> >
>=20
> --
> Mel Gorman
> Part-time Phd Student                          Linux Technology Center
> University of Limerick                         IBM Dublin Software Lab

------_=_NextPart_001_01C6FEDE.FDA60C3D
Content-Type: application/octet-stream;
	name="ia64_add_active_page_fix.patch"
Content-Transfer-Encoding: base64
Content-Description: ia64_add_active_page_fix.patch
Content-Disposition: attachment;
	filename="ia64_add_active_page_fix.patch"

LS0tIGEvYXJjaC9pYTY0L21tL2Rpc2NvbnRpZy5jCTIwMDYtMTEtMDIgMjA6MDk6NDcuMDAwMDAw
MDAwIC0wNTAwCisrKyBiL2FyY2gvaWE2NC9tbS9kaXNjb250aWcuYwkyMDA2LTExLTAyIDE5OjU3
OjI3LjAwMDAwMDAwMCAtMDUwMApAQCAtMjEsNiArMjEsNyBAQAogI2luY2x1ZGUgPGxpbnV4L2Fj
cGkuaD4KICNpbmNsdWRlIDxsaW51eC9lZmkuaD4KICNpbmNsdWRlIDxsaW51eC9ub2RlbWFzay5o
PgorI2luY2x1ZGUgPGxpbnV4L2tleGVjLmg+CiAjaW5jbHVkZSA8YXNtL3BnYWxsb2MuaD4KICNp
bmNsdWRlIDxhc20vdGxiLmg+CiAjaW5jbHVkZSA8YXNtL21lbWluaXQuaD4KQEAgLTY1Myw4ICs2
NTQsNiBAQCB2b2lkIGNhbGxfcGVybm9kZV9tZW1vcnkodW5zaWduZWQgbG9uZyBzCiBzdGF0aWMg
X19pbml0IGludCBjb3VudF9ub2RlX3BhZ2VzKHVuc2lnbmVkIGxvbmcgc3RhcnQsIHVuc2lnbmVk
IGxvbmcgbGVuLCBpbnQgbm9kZSkKIHsKIAl1bnNpZ25lZCBsb25nIGVuZCA9IHN0YXJ0ICsgbGVu
OwotCi0JYWRkX2FjdGl2ZV9yYW5nZShub2RlLCBzdGFydCA+PiBQQUdFX1NISUZULCBlbmQgPj4g
UEFHRV9TSElGVCk7CiAJbWVtX2RhdGFbbm9kZV0ubnVtX3BoeXNwYWdlcyArPSBsZW4gPj4gUEFH
RV9TSElGVDsKIAlpZiAoc3RhcnQgPD0gX19wYShNQVhfRE1BX0FERFJFU1MpKQogCQltZW1fZGF0
YVtub2RlXS5udW1fZG1hX3BoeXNwYWdlcyArPQpAQCAtNjY5LDcgKzY2OCwzMSBAQCBzdGF0aWMg
X19pbml0IGludCBjb3VudF9ub2RlX3BhZ2VzKHVuc2lnCiAKIAlyZXR1cm4gMDsKIH0KK3N0YXRp
YyBfX2luaXQgaW50IGFkZF9hY3RpdmVfcmFuZ2Vfd3JhcHBlcih1bnNpZ25lZCBsb25nIHN0YXJ0
LCAKKwkJdW5zaWduZWQgbG9uZyBsZW4sIGludCBub2RlKQoreworCXVuc2lnbmVkIGxvbmcgZW5k
ID0gc3RhcnQgKyBsZW47CisJYWRkX2FjdGl2ZV9yYW5nZShub2RlLCBzdGFydCA+PiBQQUdFX1NI
SUZULCBlbmQgPj4gUEFHRV9TSElGVCk7CisJcmV0dXJuIDA7Cit9CiAKK3N0YXRpYyBpbnQgX19p
bml0CitmaWx0ZXJfcGVybm9kZV9tZW1vcnkgKHVuc2lnbmVkIGxvbmcgc3RhcnQsIHVuc2lnbmVk
IGxvbmcgZW5kLCB2b2lkICphcmcpCit7CisJdm9pZCAoKmZ1bmMpKHVuc2lnbmVkIGxvbmcsIHVu
c2lnbmVkIGxvbmcsIGludCk7CisJZnVuYyA9IGFyZzsKKworI2lmZGVmIENPTkZJR19LRVhFQwor
CWlmIChzdGFydCA+IGNyYXNoa19yZXMuc3RhcnQgJiYgc3RhcnQgPCBjcmFzaGtfcmVzLmVuZCkK
KwkJc3RhcnQgPSBtYXgoc3RhcnQsIGNyYXNoa19yZXMuZW5kKTsKKwlpZiAoZW5kID4gY3Jhc2hr
X3Jlcy5zdGFydCAmJiBlbmQgPCBjcmFzaGtfcmVzLmVuZCkKKwkJZW5kID0gbWluKGVuZCwgY3Jh
c2hrX3Jlcy5zdGFydCk7CisjZW5kaWYKKwlpZiAoc3RhcnQgPCBlbmQpCisJCWNhbGxfcGVybm9k
ZV9tZW1vcnkoX19wYShzdGFydCksIGVuZCAtIHN0YXJ0LCBmdW5jKTsKKworCXJldHVybiAwOwor
fQogLyoqCiAgKiBwYWdpbmdfaW5pdCAtIHNldHVwIHBhZ2UgdGFibGVzCiAgKgpAQCAtNjg5LDYg
KzcxMiw3IEBAIHZvaWQgX19pbml0IHBhZ2luZ19pbml0KHZvaWQpCiAJYXJjaF9zcGFyc2VfaW5p
dCgpOwogCiAJZWZpX21lbW1hcF93YWxrKGZpbHRlcl9yc3ZkX21lbW9yeSwgY291bnRfbm9kZV9w
YWdlcyk7CisJZWZpX21lbW1hcF93YWxrKGZpbHRlcl9wZXJub2RlX21lbW9yeSwgYWRkX2FjdGl2
ZV9yYW5nZV93cmFwcGVyKTsKIAogI2lmZGVmIENPTkZJR19WSVJUVUFMX01FTV9NQVAKIAl2bWFs
bG9jX2VuZCAtPSBQQUdFX0FMSUdOKEFMSUdOKG1heF9sb3dfcGZuLCBNQVhfT1JERVJfTlJfUEFH
RVMpICoK

------_=_NextPart_001_01C6FEDE.FDA60C3D--
