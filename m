From: Jason Baron <jbaron@redhat.com>
Date: Fri, 14 Jan 2005 16:52:41 +0000
Subject: [patch] add BUG call to overlapping vma fix
Message-Id: <Pine.LNX.4.44.0501141131310.12942-200000@dhcp83-105.boston.redhat.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="279734611-1232684541-1105721561=:12942"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

--279734611-1232684541-1105721561=:12942
Content-Type: TEXT/PLAIN; charset=US-ASCII


hi,

It seems that in ia64_elf32_init, instead of calling return, if we insert
an overlapping vma, we should instead BUG(). We should never get into this
code path, because the vma's are set above PAGE_OFFSET, and thus a
Xmalicious user can not trigger this code path. This change is being
suggested mainly for clarity. Thanks to Stephen Tweedie for pointing out
that returning early in ia64_elf32_init could have unpredictable results.

thanks,

-Jason

--279734611-1232684541-1105721561=:12942
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="overlap-BUG.patch"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.44.0501141152410.12942@dhcp83-105.boston.redhat.com>
Content-Description: overlapping vma BUG() addition
Content-Disposition: attachment; filename="overlap-BUG.patch"

LS0tIGxpbnV4L2FyY2gvaWE2NC9pYTMyL2JpbmZtdF9lbGYzMi5jLmJhawlG
cmkgSmFuIDE0IDExOjIyOjA2IDIwMDUNCisrKyBsaW51eC9hcmNoL2lhNjQv
aWEzMi9iaW5mbXRfZWxmMzIuYwlGcmkgSmFuIDE0IDExOjIzOjE5IDIwMDUN
CkBAIC0xMDMsNyArMTAzLDcgQEAgaWE2NF9lbGYzMl9pbml0IChzdHJ1Y3Qg
cHRfcmVncyAqcmVncykNCiAJCQlpZiAoaW5zZXJ0X3ZtX3N0cnVjdChjdXJy
ZW50LT5tbSwgdm1hKSkgew0KIAkJCQlrbWVtX2NhY2hlX2ZyZWUodm1fYXJl
YV9jYWNoZXAsIHZtYSk7DQogCQkJCXVwX3dyaXRlKCZjdXJyZW50LT5tbS0+
bW1hcF9zZW0pOw0KLQkJCQlyZXR1cm47DQorCQkJCUJVRygpOw0KIAkJCX0N
CiAJCX0NCiAJCXVwX3dyaXRlKCZjdXJyZW50LT5tbS0+bW1hcF9zZW0pOw0K
QEAgLTEzMCw3ICsxMzAsNyBAQCBpYTY0X2VsZjMyX2luaXQgKHN0cnVjdCBw
dF9yZWdzICpyZWdzKQ0KIAkJCWlmIChpbnNlcnRfdm1fc3RydWN0KGN1cnJl
bnQtPm1tLCB2bWEpKSB7DQogCQkJCWttZW1fY2FjaGVfZnJlZSh2bV9hcmVh
X2NhY2hlcCwgdm1hKTsNCiAJCQkJdXBfd3JpdGUoJmN1cnJlbnQtPm1tLT5t
bWFwX3NlbSk7DQotCQkJCXJldHVybjsNCisJCQkJQlVHKCk7DQogCQkJfQ0K
IAkJfQ0KIAkJdXBfd3JpdGUoJmN1cnJlbnQtPm1tLT5tbWFwX3NlbSk7DQpA
QCAtMTUzLDcgKzE1Myw3IEBAIGlhNjRfZWxmMzJfaW5pdCAoc3RydWN0IHB0
X3JlZ3MgKnJlZ3MpDQogCQkJaWYgKGluc2VydF92bV9zdHJ1Y3QoY3VycmVu
dC0+bW0sIHZtYSkpIHsNCiAJCQkJa21lbV9jYWNoZV9mcmVlKHZtX2FyZWFf
Y2FjaGVwLCB2bWEpOw0KIAkJCQl1cF93cml0ZSgmY3VycmVudC0+bW0tPm1t
YXBfc2VtKTsNCi0JCQkJcmV0dXJuOw0KKwkJCQlCVUcoKTsNCiAJCQl9DQog
CQl9DQogCQl1cF93cml0ZSgmY3VycmVudC0+bW0tPm1tYXBfc2VtKTsNCg==
--279734611-1232684541-1105721561=:12942--
