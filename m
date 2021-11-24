From: Michael Ellerman <mpe@ellerman.id.au>
Date: Wed, 24 Nov 2021 23:07:23 +0000
Subject: Re: [PATCH 1/1] futex: Wireup futex_waitv syscall
Message-Id: <87lf1dp2z8.fsf@mpe.ellerman.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <CAK8P3a3pQW59NVF=5P+ZiBjNJmnWh+iTZUHvqHBrXkHA6pMd4g@mail.gmail.com>
 <20211124132112.11641-1-andrealmeid@collabora.com>
In-Reply-To: <20211124132112.11641-1-andrealmeid@collabora.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="macroman"
Content-Transfer-Encoding: base64
To: =?utf-8?Q?Andr=C3=A9?= Almeida <andrealmeid@collabora.com>, linux-kernel@vger.kernel.org, arnd@arndb.de, geert@linux-m68k.org, monstr@monstr.eu, ysato@users.sourceforge.jp, dalias@libc.org, davem@davemloft.net, chris@zankel.net, jcmvbkbc@gmail.com, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org
Cc: akpm@linux-foundation.org, andrealmeid@collabora.com, bigeasy@linutronix.de, boqun.feng@gmail.com, linux-next@vger.kernel.org, lkft-triage@lists.linaro.org, longman@redhat.com, minchan@kernel.org, mingo@redhat.com, naresh.kamboju@linaro.org, peterz@infradead.org, rob@landley.net, senozhatsky@chromium.org, sfr@canb.auug.org.au, umgwanakikbuti@gmail.com, will@kernel.org

QW5kcsOpIEFsbWVpZGEgPGFuZHJlYWxtZWlkQGNvbGxhYm9yYS5jb20+IHdyaXRlczoKPiBkaWZm
IC0tZ2l0IGEvYXJjaC9wb3dlcnBjL2tlcm5lbC9zeXNjYWxscy9zeXNjYWxsLnRibCBiL2FyY2gv
cG93ZXJwYy9rZXJuZWwvc3lzY2FsbHMvc3lzY2FsbC50YmwKPiBpbmRleCA3YmVmOTE3Y2M4NGUu
LjE1MTA5YWY5ZDA3NSAxMDA2NDQKPiAtLS0gYS9hcmNoL3Bvd2VycGMva2VybmVsL3N5c2NhbGxz
L3N5c2NhbGwudGJsCj4gKysrIGIvYXJjaC9wb3dlcnBjL2tlcm5lbC9zeXNjYWxscy9zeXNjYWxs
LnRibAo+IEBAIC01MjgsMyArNTI4LDQgQEAKPiAgNDQ2CWNvbW1vbglsYW5kbG9ja19yZXN0cmlj
dF9zZWxmCQlzeXNfbGFuZGxvY2tfcmVzdHJpY3Rfc2VsZgo+ICAjIDQ0NyByZXNlcnZlZCBmb3Ig
bWVtZmRfc2VjcmV0Cj4gIDQ0OAljb21tb24JcHJvY2Vzc19tcmVsZWFzZQkJc3lzX3Byb2Nlc3Nf
bXJlbGVhc2UKPiArNDQ5CWNvbW1vbiAgZnV0ZXhfd2FpdHYgICAgICAgICAgICAgICAgICAgICBz
eXNfZnV0ZXhfd2FpdHYKClRlc3RlZC1ieTogTWljaGFlbCBFbGxlcm1hbiA8bXBlQGVsbGVybWFu
LmlkLmF1PiAocG93ZXJwYykKClRoZSBzZWxmdGVzdCBkb2Vzbid0IGJ1aWxkIHdpdGggb2xkIGhl
YWRlcnMsIEkgbmVlZGVkIHRoaXM6CgpkaWZmIC0tZ2l0IGEvdG9vbHMvdGVzdGluZy9zZWxmdGVz
dHMvZnV0ZXgvaW5jbHVkZS9mdXRleDJ0ZXN0LmggYi90b29scy90ZXN0aW5nL3NlbGZ0ZXN0cy9m
dXRleC9pbmNsdWRlL2Z1dGV4MnRlc3QuaAppbmRleCA5ZDMwNTUyMGU4NDkuLmU2NDIyMzIxZTlk
MCAxMDA2NDQKLS0tIGEvdG9vbHMvdGVzdGluZy9zZWxmdGVzdHMvZnV0ZXgvaW5jbHVkZS9mdXRl
eDJ0ZXN0LmgKKysrIGIvdG9vbHMvdGVzdGluZy9zZWxmdGVzdHMvZnV0ZXgvaW5jbHVkZS9mdXRl
eDJ0ZXN0LmgKQEAgLTgsNiArOCwxMCBAQAoKICNkZWZpbmUgdTY0X3RvX3B0cih4KSAoKHZvaWQg
KikodWludHB0cl90KSh4KSkKCisjaWZuZGVmIF9fTlJfZnV0ZXhfd2FpdHYKKyNkZWZpbmUgX19O
Ul9mdXRleF93YWl0diA0NDkKKyNlbmRpZgorCiAvKioKICAqIGZ1dGV4X3dhaXR2IC0gV2FpdCBh
dCBtdWx0aXBsZSBmdXRleGVzLCB3YWtlIG9uIGFueQogICogQHdhaXRlcnM6ICAgIEFycmF5IG9m
IHdhaXRlcnMKCgpjaGVlcnM=
