From: Francis Galiegue <fg@mandrakesoft.com>
Date: Fri, 17 Nov 2000 14:55:30 +0000
Subject: Re: [Linux-ia64] toolchain status
MIME-Version: 1
Content-Type: multipart/mixed; boundary="-1463800575-1395061571-974472930=:8285"
Message-Id: <marc-linux-ia64-105590678205739@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

---1463800575-1395061571-974472930=:8285
Content-Type: TEXT/PLAIN; charset=US-ASCII

On Thu, 16 Nov 2000, H . J . Lu wrote:

> > > There is no DT_INIT_ARRAY in libc.so. Even if there is DT_INIT_ARRAY,
> > > I still don't know how to use it to tell where DT_INIT points to.
> > 
> > Easy enough -- you know from DT_PLTGOT what the GP is for the DSO.
> > If *(long *)(DT_INIT + 8) == GP, then you can assume that DT_INIT
> > is a descriptor instead of an offset.
> > 
> 
> Thanks. This patch seems to work for me.
> 

I don't know which version this patch is supposed to apply to, but it doesn't
apply as is on the stock FSF tree. "Corrected" patch for this tree is attached,
in case it is of interest for someone.

Now if only I understood what you were talking about :)

-- 
Francis Galiegue, fg@mandrakesoft.com
"Programming is a race between programmers, who try and make more and more
idiot-proof software, and universe, which produces more and more remarkable
idiots. Until now, universe leads the race"  -- R. Cook

---1463800575-1395061571-974472930=:8285
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="glibc-2.2-dldt-hjlu.patch"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.21.0011171555300.8285@toy.mandrakesoft.com>
Content-Description: 
Content-Disposition: attachment; filename="glibc-2.2-dldt-hjlu.patch"

ZGlmZiAtdXJOIGdsaWJjLTIuMi5vbGQvc3lzZGVwcy9pYTY0L2RsLWxvb2t1
cGNmZy5oIGdsaWJjLTIuMi9zeXNkZXBzL2lhNjQvZGwtbG9va3VwY2ZnLmgN
Ci0tLSBnbGliYy0yLjIub2xkL3N5c2RlcHMvaWE2NC9kbC1sb29rdXBjZmcu
aAlUaHUgTm92IDE2IDE4OjU1OjE2IDIwMDANCisrKyBnbGliYy0yLjIvc3lz
ZGVwcy9pYTY0L2RsLWxvb2t1cGNmZy5oCVRodSBOb3YgMTYgMTk6MDM6NDYg
MjAwMA0KQEAgLTM5LDUgKzM5LDEzIEBADQogCQkJCQlFbGZXKEFkZHIpIHN0
YXJ0KTsNCiANCiAjZGVmaW5lIERMX0ZVTkNUSU9OX0FERFJFU1MobWFwLCBh
ZGRyKSBfZGxfZnVuY3Rpb25fYWRkcmVzcyAoKG1hcCksIChhZGRyKSkNCisj
aWYgMA0KICNkZWZpbmUgRExfRFRfSU5JVF9BRERSRVNTKG1hcCwgYWRkcikg
RExfRlVOQ1RJT05fQUREUkVTUyAoKG1hcCksIChhZGRyKSkNCiAjZGVmaW5l
IERMX0RUX0ZJTklfQUREUkVTUyhtYXAsIGFkZHIpIERMX0ZVTkNUSU9OX0FE
RFJFU1MgKChtYXApLCAoYWRkcikpDQorI2Vsc2UNCisjZGVmaW5lIERMX0RU
X0lOSVRfQUREUkVTUyhtYXAsIGFkZHIpCQkJCQkgICAgICBcDQorICAoKG1h
cCktPmxfaW5mb1tEVF9QTFRHT1RdLT5kX3VuLmRfcHRyID09ICooRWxmNjRf
QWRkciAqKSAoKGFkZHIpICsgOCkgICAgICAgXA0KKyAgID8gKGFkZHIpIDog
RExfRlVOQ1RJT05fQUREUkVTUyAobWFwLCBhZGRyKSkNCisjZGVmaW5lIERM
X0RUX0ZJTklfQUREUkVTUyhtYXAsIGFkZHIpIERMX0RUX0lOSVRfQUREUkVT
UyAobWFwLCBhZGRyKQ0KKyNlbmRpZg0KKw0K
---1463800575-1395061571-974472930=:8285--

