From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 03 Feb 2005 22:48:55 +0000
Subject: RE: [patch] fix per-CPU MCA mess and make UP kernels work again
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02D8CCF5@scsmsx401.amr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C50A42.8AE54285"
List-Id: <linux-ia64.vger.kernel.org>
References: <16887.1203.470842.161249@napali.hpl.hp.com>
In-Reply-To: <16887.1203.470842.161249@napali.hpl.hp.com>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C50A42.8AE54285
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

This patch helps some (all uses of ia64_mca_data in
mca_asm.S need to deref the pointer to get at the
actual space, instead of clobbering thigs in the
percpu area).

Also I noticed that ia64_sal_to_os_handoff_state
hasn't been replicated ... won't we need that too?

-Tony

------_=_NextPart_001_01C50A42.8AE54285
Content-Type: application/octet-stream;
	name="forruss.patch"
Content-Transfer-Encoding: base64
Content-Description: forruss.patch
Content-Disposition: attachment;
	filename="forruss.patch"

PT09PT0gYXJjaC9pYTY0L2tlcm5lbC9tY2FfYXNtLlMgMS4xOSB2cyBlZGl0ZWQgPT09PT0KLS0t
IDEuMTkvYXJjaC9pYTY0L2tlcm5lbC9tY2FfYXNtLlMJMjAwNS0wMS0yNiAxNDoyNjo0MCAtMDg6
MDAKKysrIGVkaXRlZC9hcmNoL2lhNjQva2VybmVsL21jYV9hc20uUwkyMDA1LTAyLTAzIDE0OjAy
OjMzIC0wODowMApAQCAtMzExLDYgKzMxMSw4IEBACiAJLy8gU2V0dXAgbmV3IHN0YWNrIGZyYW1l
IGZvciBPU19NQ0EgaGFuZGxpbmcKIAlHRVRfVEhJU19QQUREUihyMiwgaWE2NF9tY2FfZGF0YSkK
IAk7OworCWxkOCByMiA9IFtyMl0KKwk7OwogCWFkZCByMyA9IElBNjRfTUNBX0NQVV9TVEFDS0ZS
QU1FX09GRlNFVCwgcjIKIAlhZGQgcjIgPSBJQTY0X01DQV9DUFVfUkJTVE9SRV9PRkZTRVQsIHIy
CiAJOzsKQEAgLTMxOCw2ICszMjAsOCBAQAogCiAJR0VUX1RISVNfUEFERFIocjIsIGlhNjRfbWNh
X2RhdGEpCiAJOzsKKwlsZDggcjIgPSBbcjJdCisJOzsKIAlhZGQgcjIgPSBJQTY0X01DQV9DUFVf
U1RBQ0tfT0ZGU0VUK0lBNjRfTUNBX1NUQUNLX1NJWkUtMTYsIHIyCiAJOzsKIAltb3YgcjEyPXIy
CQkvLyBlc3RhYmxpc2ggbmV3IHN0YWNrLXBvaW50ZXIKQEAgLTM0MCw2ICszNDQsOCBAQAogCTs7
CiAJYWRkIHIyID0gSUE2NF9NQ0FfQ1BVX1NUQUNLRlJBTUVfT0ZGU0VULCByMgogCTs7CisJbGQ4
IHIyID0gW3IyXQorCTs7CiAJbW92bCAgICByND1JQTY0X1BTUl9NQwogCTs7CiAJcnNlX3JldHVy
bl9jb250ZXh0KHI0LHIzLHIyKQkvLyBzd2l0Y2ggZnJvbSBpbnRlcnJ1cHQgY29udGV4dCBmb3Ig
UlNFCkBAIC0zODIsNiArMzg4LDggQEAKIC8vICB0byB2aXJ0dWFsIGFkZHJlc3NpbmcgbW9kZS4K
IAlHRVRfVEhJU19QQUREUihyMiwgaWE2NF9tY2FfZGF0YSkKIAk7OworCWxkOCByMiA9IFtyMl0K
Kwk7OwogCWFkZCByMiA9IElBNjRfTUNBX0NQVV9QUk9DX1NUQVRFX0RVTVBfT0ZGU0VULCByMgog
CTs7CiAvLyBzYXZlIGFyLk5hVApAQCAtNjE0LDYgKzYyMiw4IEBACiAKIC8vIFJlc3RvcmUgYmFu
azEgR1IxNi0zMQogCUdFVF9USElTX1BBRERSKHIyLCBpYTY0X21jYV9kYXRhKQorCTs7CisJbGQ4
IHIyID0gW3IyXQogCTs7CiAJYWRkIHIyID0gSUE2NF9NQ0FfQ1BVX1BST0NfU1RBVEVfRFVNUF9P
RkZTRVQsIHIyCiAK

------_=_NextPart_001_01C50A42.8AE54285--
