From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Thu, 14 Nov 2002 20:32:20 +0000
Subject: RE: [Linux-ia64] Re: memcpy failure
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C28C1C.EE50D860"
Message-Id: <marc-linux-ia64-105590709805435@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805424@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805424@msgid-missing>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C28C1C.EE50D860
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Here is the patch that I promised.

Bjorn, would you please apply it to the 2.4 tree? and
David, would you please apply it to the 2.5 tree?

Thanks.

- Ken


-----Original Message-----
From: Chen, Kenneth W=20
Sent: Thursday, November 14, 2002 7:53 AM
To: Matthew Wilcox; Christian Cotte-Barrot
Cc: linux-ia64@linuxia64.org
Subject: RE: [Linux-ia64] Re: memcpy failure



> >On Thu, Nov 14, 2002 at 10:01:44AM +0100, Christian Cotte-Barrot =
wrote:
> > But memcpy from memcpy.S is returning a pointer to dest area.
> > That would lead to quasi non-portable code when the return from =
memcopy
> > is correctly checked depending on which memcopy function is =
addressed.
> > But BTW, is it meaningful to take into account a return code
> > that is always the same and which value is known in advance ?
> > Does memcpy suppose to failed in some cases ?

> no, memcpy cannot fail (you get a SIGSEGV in userspace or an MCA in
> kernel space).  checking the return value is meaningless.

That's what I feel as well that it is kind of silly to return something =
that the caller already has. BUt then, I'm not here to judge the =
specification ;-)

Anyhow, the fix is fairly easy and won't affect the code size as well as =
the copy throughput, I should have a patch ready shortly to make =
everyone happy!

- Ken

_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64

------_=_NextPart_001_01C28C1C.EE50D860
Content-Type: application/octet-stream;
	name="memcpy_mck.fix.patch"
Content-Transfer-Encoding: base64
Content-Description: memcpy_mck.fix.patch
Content-Disposition: attachment;
	filename="memcpy_mck.fix.patch"

LS0tIGxpbnV4L2FyY2gvaWE2NC9saWIvbWVtY3B5X21jay5TLm9yaWcJRnJpIE5vdiAgOCAxODow
NTowNSAyMDAyCisrKyBsaW51eC9hcmNoL2lhNjQvbGliL21lbWNweV9tY2suUwlUaHUgTm92IDE0
IDExOjMzOjUzIDIwMDIKQEAgLTYsNyArNiwxMCBAQAogICoJaW4xOglzb3VyY2UgYWRkcmVzcwog
ICoJaW4yOgludW1iZXIgb2YgYnl0ZXMgdG8gY29weQogICogT3V0cHV0OgotICogCTAgaWYgc3Vj
Y2Vzcywgb3IgbnVtYmVyIG9mIGJ5dGUgTk9UIGNvcGllZCBpZiBlcnJvciBvY2N1cnJlZC4KKyAq
CWZvciBiY29weTogICAgIHJldHVybiBub3RoaW5nCisgKglmb3IgbWVtY3B5OiAgICByZXRydW4g
ZGVzdAorICogCWZvciBjb3B5X3VzZXI6IHJldHVybiAwIGlmIHN1Y2Nlc3MsCisgKgkJICAgICAg
IG9yIG51bWJlciBvZiBieXRlIE5PVCBjb3BpZWQgaWYgZXJyb3Igb2NjdXJyZWQuCiAgKgogICog
Q29weXJpZ2h0IChDKSAyMDAyIEludGVsIENvcnAuCiAgKiBDb3B5cmlnaHQgKEMpIDIwMDIgS2Vu
IENoZW4gPGtlbm5ldGgudy5jaGVuQGludGVsLmNvbT4KQEAgLTg2LDYgKzg5LDcgQEAKIAlhbmQJ
cjI4PTB4NyxpbjAKIAlhbmQJcjI5PTB4NyxpbjEKIAltb3YJZjY9ZjAKKwltb3YJcmV0dmFsPWlu
MAogCWJyLmNvbmQuc3B0ayAuY29tbW9uX2NvZGUKIAk7OwogRU5EKG1lbWNweSkKQEAgLTk3LDcg
KzEwMSw3IEBACiAJbW92CWY2PWYxCiAJbW92CXNhdmVkX2luMD1pbjAJLy8gc2F2ZSBkZXN0IHBv
aW50ZXIKIAltb3YJc2F2ZWRfaW4xPWluMQkvLyBzYXZlIHNyYyBwb2ludGVyCi0JbW92CXNhdmVk
X2luMj1pbjIJLy8gc2F2ZSBsZW4KKwltb3YJcmV0dmFsPXIwCS8vIGluaXRpYWxpemUgcmV0dXJu
IHZhbHVlCiAJOzsKIC5jb21tb25fY29kZToKIAljbXAuZ3QJcDE1LHAwPTgsaW4yCS8vIGNoZWNr
IGZvciBzbWFsbCBzaXplCkBAIC0xMDUsNyArMTA5LDcgQEAKIAljbXAubmUJcDE0LHAwPTAscjI5
CS8vIGNoZWNrIHNyYyBhbGlnbm1lbnQKIAlhZGQJc3JjMD0wLGluMQogCXN1YglyMzA9OCxyMjgJ
Ly8gZm9yIC5hbGlnbl9kZXN0Ci0JbW92CXJldHZhbD1yMAkvLyBpbml0aWFsaXplIHJldHVybiB2
YWx1ZQorCW1vdglzYXZlZF9pbjI9aW4yCS8vIHNhdmUgbGVuCiAJOzsKIAlhZGQJZHN0MD0wLGlu
MAogCWFkZAlkc3QxPTEsaW4wCS8vIGRlc3Qgb2RkIGluZGV4Cg==

------_=_NextPart_001_01C28C1C.EE50D860--

