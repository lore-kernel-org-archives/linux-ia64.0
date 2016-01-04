From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 04 Jan 2016 18:20:50 +0000
Subject: RE: [PATCH 6/6] arm64: switch to relative exception tables
Message-Id: <3908561D78D1C84285E8C5FCA982C28F39FA127B@ORSMSX114.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1451837157-447-1-git-send-email-ard.biesheuvel@linaro.org>
 <1451837157-447-7-git-send-email-ard.biesheuvel@linaro.org>
 <20160104144643.GE1616@arm.com> <568AB65A.8030901@zytor.com>
In-Reply-To: <568AB65A.8030901@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "H. Peter Anvin" <hpa@zytor.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: "linux-alpha@vger.kernel.org" <linux-alpha@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "mingo@redhat.com" <mingo@redhat.com>, "heiko.carstens@de.ibm.com" <heiko.carstens@de.ibm.com>, "schwidefsky@de.ibm.com" <schwidefsky@de.ibm.com>, "mattst88@gmail.com" <mattst88@gmail.com>, "ink@jurassic.park.msu.ru" <ink@jurassic.park.msu.ru>, "rth@twiddle.net" <rth@twiddle.net>, "Yu, Fenghua" <fenghua.yu@intel.com>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "arnd@arndb.de" <arnd@arndb.de>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mark.rutland@arm.com" <mark.rutland@arm.com>, "marc.zyngier@arm.com" <marc.zyngier@arm.com>

PiBNYXkgSSBodW1ibHkgYXNrIHdoeSB0aGUgW0Zpbm5pc2hdIHlvdSBkb24ndCB1c2UgdGhlIGVx
dWl2YWxlbnQgb2YgdGhlDQo+IHg4NiBfQVNNX0VYVEFCTEUoKSBtYWNybz8gIEluIGZhY3QsIHdo
eSBkb24ndCB3ZSBtYWtlIHRoYXQgb25lIGdlbmVyaWMsIHRvbz8NCg0KSSdtIG1lc3Npbmcgd2l0
aCB0aGF0IHJpZ2h0IG5vdyAod2l0aCBoZWxwIGZyb20gQW5keSBMdXRvbWlyc2tpIGFuZCBCb3Jp
cykgdG8NCmFkZCBkaWZmZXJlbnQgY2xhc3NlcyBvZiBleGNlcHRpb24gdGFibGUgKHNvIEkgY2Fu
IHRhZyBzb21lIGluc3RydWN0aW9ucyBhcyBiZWluZw0Kc3VpdGFibGUgZm9yIGZpeHVwIGZyb20g
dGhlIG1hY2hpbmUgY2hlY2sgaGFuZGxlcikuICBTbyBpdCBtaWdodCBub3QgYmUgZ2VuZXJpYw0K
Zm9yIG11Y2ggbG9uZ2VyLg0KDQpodHRwOi8vbWFyYy5pbmZvLz9sPWxpbnV4LWtlcm5lbCZtPTE0
NTE4NzA3OTUwNDg0NiZ3PTINCg0KLVRvbnkNCg=
