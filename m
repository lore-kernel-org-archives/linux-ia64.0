From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 15 Jul 2004 23:53:33 +0000
Subject: RE: free bootmem feedback patch
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F01AA9ECE@scsmsx401.amr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C46AC6.F012ECB9"
List-Id: <linux-ia64.vger.kernel.org>
References: <40F46962.4090604@sgi.com>
In-Reply-To: <40F46962.4090604@sgi.com>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C46AC6.F012ECB9
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

>> still be looking at a couple of minutes :-(  Since I only got a
>> 55% reduction, rather than a factor of 64 I expect that modifying
>> to look an larger order pages may have diminishing returns.
>
>I'll work relative to this for the rest. I'd recommend using __ffs()
>instead of the loop. Also, combining this with a specialized page
>freeing function that doesn't e.g. fiddle with page references

The returns to freeing larger pages do indeed diminish fast.  I
added simple "look at the next word" and "look at the next
three words" hacks to see what the times looked like with
order=3D7 and order=3D8 ... and found that order 8 is only 1.8%
faster than order 6.

>The common case is the bitmap and mem_map[] starting at 0.

Sadly not quite 0.  PG_reserved is set for each page structure
and must be cleared ... so we have to touch every page structure
at least once :-(  On a 4TB machine thats 0.25 billion cache
misses (with a 16K page).


>remaining cases are pretty marginalized. This can actually be checked
>at runtime by checking the alignment of ->node_boot_start, e.g. maybe
>if  (!~v && !((__pa(bdata->node_boot_start) >> PAGE_SHIFT) &=20
>((1 << MAX_ORDER) - 1)))
>instead of just !~v.

That check can be done once (for each node) outside the loop. The
exact expression used to set the "gofast" variable in my patch
make need some tweaking

New patch attached.

-Tony

------_=_NextPart_001_01C46AC6.F012ECB9
Content-Type: application/octet-stream;
	name="bootmem.patch"
Content-Transfer-Encoding: base64
Content-Description: bootmem.patch
Content-Disposition: attachment;
	filename="bootmem.patch"

LS0tIGxpbnV4LTIuNi44LXJjMS1vcmlnL21tL2Jvb3RtZW0uYwkyMDA0LTA3LTExIDEwOjM0OjE5
LjAwMDAwMDAwMCAtMDcwMAorKysgbGludXgtMi42LjgtcmMxL21tL2Jvb3RtZW0uYwkyMDA0LTA3
LTE1IDE2OjQ1OjA0LjI1NTE5NTcxNyAtMDcwMApAQCAtMjU5LDYgKzI1OSw3IEBACiAJdW5zaWdu
ZWQgbG9uZyBpLCBjb3VudCwgdG90YWwgPSAwOwogCXVuc2lnbmVkIGxvbmcgaWR4OwogCXVuc2ln
bmVkIGxvbmcgKm1hcDsgCisJaW50IGdvZmFzdCA9IDA7CiAKIAlCVUdfT04oIWJkYXRhLT5ub2Rl
X2Jvb3RtZW1fbWFwKTsKIApAQCAtMjY3LDkgKzI2OCwyMyBAQAogCXBhZ2UgPSB2aXJ0X3RvX3Bh
Z2UocGh5c190b192aXJ0KGJkYXRhLT5ub2RlX2Jvb3Rfc3RhcnQpKTsKIAlpZHggPSBiZGF0YS0+
bm9kZV9sb3dfcGZuIC0gKGJkYXRhLT5ub2RlX2Jvb3Rfc3RhcnQgPj4gUEFHRV9TSElGVCk7CiAJ
bWFwID0gYmRhdGEtPm5vZGVfYm9vdG1lbV9tYXA7CisJaWYgKGJkYXRhLT5ub2RlX2Jvb3Rfc3Rh
cnQgPT0gMCB8fAorCSAgICBmZnMoYmRhdGEtPm5vZGVfYm9vdF9zdGFydCkgLSBQQUdFX1NISUZU
ID4gZmZzKEJJVFNfUEVSX0xPTkcpKQorCQlnb2Zhc3QgPSAxOwogCWZvciAoaSA9IDA7IGkgPCBp
ZHg7ICkgewogCQl1bnNpZ25lZCBsb25nIHYgPSB+bWFwW2kgLyBCSVRTX1BFUl9MT05HXTsKLQkJ
aWYgKHYpIHsKKwkJaWYgKGdvZmFzdCAmJiB2ID09IH4wVUwpIHsKKwkJCWludCBqOworCisJCQlj
b3VudCArPSBCSVRTX1BFUl9MT05HOworCQkJQ2xlYXJQYWdlUmVzZXJ2ZWQocGFnZSk7CisJCQlz
ZXRfcGFnZV9jb3VudChwYWdlLCAxKTsKKwkJCWZvciAoaiA9IDE7IGogPCBCSVRTX1BFUl9MT05H
OyBqKyspCisJCQkJQ2xlYXJQYWdlUmVzZXJ2ZWQocGFnZSArIGopOworCQkJX19mcmVlX3BhZ2Vz
KHBhZ2UsIGZmcyhCSVRTX1BFUl9MT05HKS0xKTsKKwkJCWkgKz0gQklUU19QRVJfTE9ORzsKKwkJ
CXBhZ2UgKz0gQklUU19QRVJfTE9ORzsKKwkJfSBlbHNlIGlmICh2KSB7CiAJCQl1bnNpZ25lZCBs
b25nIG07CiAJCQlmb3IgKG0gPSAxOyBtICYmIGkgPCBpZHg7IG08PD0xLCBwYWdlKyssIGkrKykg
ewogCQkJCWlmICh2ICYgbSkgewo=

------_=_NextPart_001_01C46AC6.F012ECB9--
