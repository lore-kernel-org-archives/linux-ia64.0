From: "Xu, Anthony" <anthony.xu@intel.com>
Date: Mon, 09 Jan 2006 02:36:35 +0000
Subject: [linux-ia64][PATCH] pal cache flush patch
Message-Id: <2BF508F394C196468CCBEC031320DCDF380888@pdsmsx405>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C614C5.82913B0C"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C614C5.82913B0C
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Hi all,

Because PAL spec has changed since 2002, you can goto
http://developer.intel.com/design/itanium/manuals/iiasdmanual.htm to
download new SDM, all PAL calls should be invoked with psr.ic=3D1, and
it's caller's responsibility to handle possible tlb miss.
Ia64_pal_cache_flush was written according to old spec, it is obsolete,
and this patch has ia64_pal_cache_flush conform to new spec.

Signed-off-by Anthony Xu <anthony.xu@intel.com>

------_=_NextPart_001_01C614C5.82913B0C
Content-Type: application/octet-stream;
	name="ia64_pal_cache_flush.patch"
Content-Transfer-Encoding: base64
Content-Description: ia64_pal_cache_flush.patch
Content-Disposition: attachment;
	filename="ia64_pal_cache_flush.patch"

ZGlmZiAtcnVOIGxpbnV4LTIuNi4xNS9pbmNsdWRlL2FzbS1pYTY0L3BhbC5oIGxpbnV4LTIuNi4x
NS5uZXcvaW5jbHVkZS9hc20taWE2NC9wYWwuaAotLS0gbGludXgtMi42LjE1L2luY2x1ZGUvYXNt
LWlhNjQvcGFsLmgJMjAwNi0wMS0wMyAxMToyMToxMC4wMDAwMDAwMDAgKzA4MDAKKysrIGxpbnV4
LTIuNi4xNS5uZXcvaW5jbHVkZS9hc20taWE2NC9wYWwuaAkyMDA2LTAxLTA5IDA5OjU2OjE4LjAw
MDAwMDAwMCArMDgwMApAQCAtOTI3LDcgKzkyNyw3IEBACiBpYTY0X3BhbF9jYWNoZV9mbHVzaCAo
dTY0IGNhY2hlX3R5cGUsIHU2NCBpbnZhbGlkYXRlLCB1NjQgKnByb2dyZXNzLCB1NjQgKnZlY3Rv
cikKIHsKIAlzdHJ1Y3QgaWE2NF9wYWxfcmV0dmFsIGlwcnY7Ci0JUEFMX0NBTExfSUNfT0ZGKGlw
cnYsIFBBTF9DQUNIRV9GTFVTSCwgY2FjaGVfdHlwZSwgaW52YWxpZGF0ZSwgKnByb2dyZXNzKTsK
KwlQQUxfQ0FMTChpcHJ2LCBQQUxfQ0FDSEVfRkxVU0gsIGNhY2hlX3R5cGUsIGludmFsaWRhdGUs
ICpwcm9ncmVzcyk7CiAJaWYgKHZlY3RvcikKIAkJKnZlY3RvciA9IGlwcnYudjA7CiAJKnByb2dy
ZXNzID0gaXBydi52MTsK

------_=_NextPart_001_01C614C5.82913B0C--
