From: Mike Galbraith <efault@gmx.de>
Date: Wed, 21 May 2003 09:30:39 +0000
Subject: [Linux-ia64] Re: web page on O(1) scheduler
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=====================_59349421==_"
Message-Id: <marc-linux-ia64-105590723705968@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705966@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705966@msgid-missing>
To: linux-ia64@vger.kernel.org

--=====================_59349421==_
Content-Type: text/plain; charset="us-ascii"; format=flowed

At 11:26 AM 5/21/2003 +0200, Mike Galbraith wrote:

>Try the attached overly simplistic (KISS:) diff, and watch your starvation 
>issues be very noticably reduced.

Ahem ;-)

Now even attached.

         -Mike 
--=====================_59349421==_
Content-Type: application/octet-stream; name="xx.diff";
 x-mac-type="42494E41"; x-mac-creator="5843454C"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="xx.diff"

LS0tIGxpbnV4LTIuNS42OS9rZXJuZWwvc2NoZWQuYy5vcmcJV2VkIE1heSAyMSAwNzo0NTowMCAy
MDAzCisrKyBsaW51eC0yLjUuNjkva2VybmVsL3NjaGVkLmMJV2VkIE1heSAyMSAwODoyNzowOSAy
MDAzCkBAIC0xMjY0LDcgKzEyNjQsNyBAQAogCXRhc2tfdCAqcHJldiwgKm5leHQ7CiAJcnVucXVl
dWVfdCAqcnE7CiAJcHJpb19hcnJheV90ICphcnJheTsKLQlzdHJ1Y3QgbGlzdF9oZWFkICpxdWV1
ZTsKKwlzdHJ1Y3QgbGlzdF9oZWFkICpoZWFkLCAqY3VycjsKIAlpbnQgaWR4OwogCiAJLyoKQEAg
LTEzMzEsOCArMTMzMSwyMiBAQAogCX0KIAogCWlkeCA9IHNjaGVkX2ZpbmRfZmlyc3RfYml0KGFy
cmF5LT5iaXRtYXApOwotCXF1ZXVlID0gYXJyYXktPnF1ZXVlICsgaWR4OwotCW5leHQgPSBsaXN0
X2VudHJ5KHF1ZXVlLT5uZXh0LCB0YXNrX3QsIHJ1bl9saXN0KTsKK25leHRfcXVldWU6CisJaGVh
ZCA9IGFycmF5LT5xdWV1ZSArIGlkeDsKKwljdXJyID0gaGVhZC0+bmV4dDsKKwluZXh0ID0gbGlz
dF9lbnRyeShjdXJyLCB0YXNrX3QsIHJ1bl9saXN0KTsKKwljdXJyID0gY3Vyci0+bmV4dDsKKwkv
KgorCSAqIElmIHdlIGFyZSBhYm91dCB0byB3cmFwIGJhY2sgdG8gdGhlIGhlYWQgb2YgdGhlIHF1
ZXVlLAorCSAqIGdpdmUgYSBsb3dlciBwcmlvcml0eSBxdWV1ZSBhIGNoYW5jZSB0byBzbmVhayBv
bmUgaW4uCisJICovCisJaWYgKGlkeCA9PSBwcmV2LT5wcmlvICYmIGN1cnIgPT0gaGVhZCAmJiBh
cnJheS0+bnJfYWN0aXZlID4gMSkgeworCQlpbnQgdG1wID0gZmluZF9uZXh0X2JpdChhcnJheS0+
Yml0bWFwLCBNQVhfUFJJTywgKytpZHgpOworCQlpZiAodG1wIDwgTUFYX1BSSU8pIHsKKwkJCWlk
eCA9IHRtcDsKKwkJCWdvdG8gbmV4dF9xdWV1ZTsKKwkJfQorCX0KIAogc3dpdGNoX3Rhc2tzOgog
CXByZWZldGNoKG5leHQpOwo=
--=====================_59349421==_--


