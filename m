From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Tue, 29 Jun 2004 09:52:32 +0000
Subject: Re: [PATCH] Quiet corrected errors (CMC/CPE)
Message-Id: <0I0200IEPE3K1Q@fjmail504.fjmail.jp.fujitsu.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------Boundary_Ns5n?WZUkt,0(am"
List-Id: <linux-ia64.vger.kernel.org>
References: <0HZS006RBU9VGJ@fjmail504.fjmail.jp.fujitsu.com>
In-Reply-To: <0HZS006RBU9VGJ@fjmail504.fjmail.jp.fujitsu.com>
To: linux-ia64@vger.kernel.org


--------------Boundary_Ns5n?WZUkt,0(am
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

Trivial patch to quiet messages about corrected errors.

Signed-off-by: Tony Luck <tony.luck@intel.com>

--------------Boundary_Ns5n?WZUkt,0(am
Content-Type: application/octet-stream; name="mca_noprintk.patch"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="mca_noprintk.patch"

ZGlmZiAtTnVyIGxpbnV4LTIuNi43L2FyY2gvaWE2NC9rZXJuZWwvbWNhLmMgbGludXgtMi42
Ljctbm9wcmludGsvYXJjaC9pYTY0L2tlcm5lbC9tY2EuYwotLS0gbGludXgtMi42LjcvYXJj
aC9pYTY0L2tlcm5lbC9tY2EuYwkyMDA0LTA2LTI0IDE0OjA0OjMyLjAwMDAwMDAwMCArMDkw
MAorKysgbGludXgtMi42Ljctbm9wcmludGsvYXJjaC9pYTY0L2tlcm5lbC9tY2EuYwkyMDA0
LTA2LTI0IDE0OjA1OjE0LjAwMDAwMDAwMCArMDkwMApAQCAtMjUzLDcgKzI1Myw3IEBACiAJ
c2FsaW5mb19sb2dfd2FrZXVwKHNhbF9pbmZvX3R5cGUsIGJ1ZmZlciwgc2l6ZSwgaXJxX3Nh
ZmUpOwogCiAJaWYgKGlycV9zYWZlKQotCQlwcmludGsoS0VSTl9JTkZPICJDUFUgJWQ6IFNB
TCBsb2cgY29udGFpbnMgJXMgZXJyb3IgcmVjb3JkXG4iLAorCQlJQTY0X01DQV9ERUJVRygi
Q1BVICVkOiBTQUwgbG9nIGNvbnRhaW5zICVzIGVycm9yIHJlY29yZFxuIiwKIAkJCXNtcF9w
cm9jZXNzb3JfaWQoKSwKIAkJCXNhbF9pbmZvX3R5cGUgPCBBUlJBWV9TSVpFKHJlY19uYW1l
KSA/IHJlY19uYW1lW3NhbF9pbmZvX3R5cGVdIDogIlVOS05PV04iKTsKIAp=

--------------Boundary_Ns5n?WZUkt,0(am--
