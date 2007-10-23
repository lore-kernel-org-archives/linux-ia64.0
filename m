From: "Luming Yu" <luming.yu@gmail.com>
Date: Tue, 23 Oct 2007 07:15:55 +0000
Subject: [PATCH] fix typo in per_cpu_offset
Message-Id: <3877989d0710230015x1640388aod98cae2fa3fc82c2@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_Part_12136_32329095.1193123755592"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org
Cc: Linux Kernel <linux-kernel@vger.kernel.org>

------=_Part_12136_32329095.1193123755592
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hello list,

there is a typo in the definition of per_cpu_offset because, for ia64,
the __per_cpu_offset is an array.

 extern unsigned long __per_cpu_offset[NR_CPUS];
-#define per_cpu_offset(x) (__per_cpu_offset(x))
+#define per_cpu_offset(x) (__per_cpu_offset[x])

Thanks,
Luming

Signed-off-by: Yu Luming <luming.yu@intel.com>

------=_Part_12136_32329095.1193123755592
Content-Type: application/octet-stream; name=correct_per_cpu_offset.patch
Content-Transfer-Encoding: base64
X-Attachment-Id: f_f8430x0q
Content-Disposition: attachment; filename=correct_per_cpu_offset.patch

ZGlmZiAtLWdpdCBhL2luY2x1ZGUvYXNtLWlhNjQvcGVyY3B1LmggYi9pbmNsdWRlL2FzbS1pYTY0
L3BlcmNwdS5oCmluZGV4IDQzYTdhYWMuLmM0ZjFlMzIgMTAwNjQ0Ci0tLSBhL2luY2x1ZGUvYXNt
LWlhNjQvcGVyY3B1LmgKKysrIGIvaW5jbHVkZS9hc20taWE2NC9wZXJjcHUuaApAQCAtNDYsNyAr
NDYsNyBAQCAjZW5kaWYKICNpZmRlZiBDT05GSUdfU01QCiAKIGV4dGVybiB1bnNpZ25lZCBsb25n
IF9fcGVyX2NwdV9vZmZzZXRbTlJfQ1BVU107Ci0jZGVmaW5lIHBlcl9jcHVfb2Zmc2V0KHgpIChf
X3Blcl9jcHVfb2Zmc2V0KHgpKQorI2RlZmluZSBwZXJfY3B1X29mZnNldCh4KSAoX19wZXJfY3B1
X29mZnNldFt4XSkKIAogLyogRXF1YWwgdG8gX19wZXJfY3B1X29mZnNldFtzbXBfcHJvY2Vzc29y
X2lkKCldLCBidXQgZmFzdGVyIHRvIGFjY2VzczogKi8KIERFQ0xBUkVfUEVSX0NQVSh1bnNpZ25l
ZCBsb25nLCBsb2NhbF9wZXJfY3B1X29mZnNldCk7Cg==
------=_Part_12136_32329095.1193123755592--
