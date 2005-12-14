From: "Zhang, Yanmin" <yanmin.zhang@intel.com>
Date: Wed, 14 Dec 2005 09:10:31 +0000
Subject: RE: [BUG] Variable stopmachine_state should be volatile
Message-Id: <8126E4F969BA254AB43EA03C59F44E840431BFE9@pdsmsx404>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C6008E.3CA08D30"
List-Id: <linux-ia64.vger.kernel.org>
References: <8126E4F969BA254AB43EA03C59F44E8404210E76@pdsmsx404>
In-Reply-To: <8126E4F969BA254AB43EA03C59F44E8404210E76@pdsmsx404>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C6008E.3CA08D30
Content-Type: text/plain;
	charset="GB2312"
Content-Transfer-Encoding: quoted-printable

>>-----Original Message-----
>>From: linux-ia64-owner@vger.kernel.org
>>[mailto:linux-ia64-owner@vger.kernel.org] On Behalf Of Zhang, Yanmin
>>Sent: 2005=C4=EA12=D4=C212=C8=D5 15:07
>>To: Luck, Tony; Arjan van de Ven; Pavel Machek
>>Cc: linux-kernel@vger.kernel.org; Pallipadi, Venkatesh; Shah, Rajesh;
>>linux-ia64@vger.kernel.org
>>Subject: RE: [BUG] Variable stopmachine_state should be volatile
>>
>>>>-----Original Message-----
>>>>From: linux-ia64-owner@vger.kernel.org
>>>>[mailto:linux-ia64-owner@vger.kernel.org] On Behalf Of Luck, Tony
>>>>Sent: 2005=C4=EA12=D4=C29=C8=D5 2:53
>>>>To: Zhang, Yanmin; Arjan van de Ven; Pavel Machek
>>>>Cc: linux-kernel@vger.kernel.org; Pallipadi, Venkatesh; Shah, =
Rajesh;
>>>>linux-ia64@vger.kernel.org
>>>>Subject: RE: [BUG] Variable stopmachine_state should be volatile
>>>>
>>>>> The right approach is to define ia64_hint to ia64_barrier in file
>>>>> include/asm-ia64/intel_intrin.h. I tested the new approach and it
>>>>> does work.
>>>>
>>>>Does that get you a "hint@pause" instruction inside the loop?  If =
not, then
>>>>it isn't all the way to the "right" approach.
>>
>>Tony,
>>
>>The approach just fixes compiler scheduling barrier problem of =
cpu_relax, and
>>there is no hint@pause inside the loop.
>>
>>Today I tried the latest icc, 9.0.027. It provides __hint, a new =
intrinsic,
>>to support hint@pause. __hint also has the meaning of compiler =
scheduling
>>barrier. So the best solution is to use __hint(0). The disassembled =
result
>>showed the new intrinsic did work.
Tony,

Here is the patch against 2.6.15-rc5.

The latest intel compiler on ia64 also adds some other intrinsic, but I =
am not sure if they're useful in kernel except __hint, so I just enabled =
ia64_hint.

Signed-off-by: Zhang Yanmin <yanmin.zhang@intel.com>


------_=_NextPart_001_01C6008E.3CA08D30
Content-Type: application/octet-stream;
	name="ia64_hint_2.6.15-rc5.patch"
Content-Transfer-Encoding: base64
Content-Description: ia64_hint_2.6.15-rc5.patch
Content-Disposition: attachment;
	filename="ia64_hint_2.6.15-rc5.patch"

ZGlmZiAtTnJhdXAgbGludXgtMi42LjE1LXJjNS9pbmNsdWRlL2FzbS1pYTY0L2ludGVsX2ludHJp
bi5oIGxpbnV4LTIuNi4xNS1yYzVfZml4L2luY2x1ZGUvYXNtLWlhNjQvaW50ZWxfaW50cmluLmgK
LS0tIGxpbnV4LTIuNi4xNS1yYzUvaW5jbHVkZS9hc20taWE2NC9pbnRlbF9pbnRyaW4uaAkyMDA1
LTA4LTI5IDA3OjQxOjAxLjAwMDAwMDAwMCArMDgwMAorKysgbGludXgtMi42LjE1LXJjNV9maXgv
aW5jbHVkZS9hc20taWE2NC9pbnRlbF9pbnRyaW4uaAkyMDA1LTEyLTE0IDAwOjU2OjEwLjAwMDAw
MDAwMCArMDgwMApAQCAtMTEzLDYgKzExMywxMyBAQCBfX3M2NCBfbTY0X2RlcF9taShjb25zdCBp
bnQgdiwgX19zNjQgcywgCiBfX3M2NCBfbTY0X3NocnAoX19zNjQgYSwgX19zNjQgYiwgY29uc3Qg
aW50IGNvdW50KTsKIF9fczY0IF9tNjRfcG9wY250KF9fczY0IGEpOwogCisvKiB2YWx1ZSBmb3Ig
YXJndW1lbnRzIHRvIHRoZSBoaW50IGluc3RydWN0aW9uICovCisjZGVmaW5lIGlhNjRfaGludF9w
YXVzZQkwCisKKy8qIGdlbmVyYXRlcyB0aGUgaXRhbml1bSBoaW50IGluc3RydWN0aW9uICovCit2
b2lkIF9faGludChjb25zdCBpbnQpOworCisKICNkZWZpbmUgaWE2NF9iYXJyaWVyKCkJCV9fbWVt
b3J5X2JhcnJpZXIoKQogCiAjZGVmaW5lIGlhNjRfc3RvcCgpCS8qIE5vdGhpbmc6IEFzIG9mIG5v
dyBzdG9wIGJpdCBpcyBnZW5lcmF0ZWQgZm9yIGVhY2gKQEAgLTEyMiw3ICsxMjksMTQgQEAgX19z
NjQgX202NF9wb3BjbnQoX19zNjQgYSk7CiAjZGVmaW5lIGlhNjRfZ2V0cmVnCQlfX2dldFJlZwog
I2RlZmluZSBpYTY0X3NldHJlZwkJX19zZXRSZWcKIAotI2RlZmluZSBpYTY0X2hpbnQoeCkKKyNk
ZWZpbmUgaWE2NF9oaW50KG1vZGUpCQkJCQkJXAorKHsJCQkJCQkJCVwKKwlzd2l0Y2ggKG1vZGUp
IHsJCQkJCQlcCisJY2FzZSBpYTY0X2hpbnRfcGF1c2U6CQkJCQlcCisJCV9faGludChpYTY0X2hp
bnRfcGF1c2UpOwkJCVwKKwkJYnJlYWs7CQkJCQkJXAorCX0JCQkJCQkJXAorfSkKIAogI2RlZmlu
ZSBpYTY0X211eDFfYnJjc3QJIDAKICNkZWZpbmUgaWE2NF9tdXgxX21peAkJIDgK

------_=_NextPart_001_01C6008E.3CA08D30--
