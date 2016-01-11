From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 11 Jan 2016 21:46:50 +0000
Subject: RE: [PATCH] efi: add conditional include of asm/early_ioremap.h
Message-Id: <3908561D78D1C84285E8C5FCA982C28F39FAA3FC@ORSMSX114.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1452456249-2974-1-git-send-email-ard.biesheuvel@linaro.org>
	<20160111144004.GD2644@codeblueprint.co.uk>
	<3908561D78D1C84285E8C5FCA982C28F39FA9F4B@ORSMSX114.amr.corp.intel.com>
 <CAKv+Gu8MMU1D3O7=2xfouSSyw_VMX22SFL4PAnwJ4Mr-Ag2N_g@mail.gmail.com>
In-Reply-To: <CAKv+Gu8MMU1D3O7=2xfouSSyw_VMX22SFL4PAnwJ4Mr-Ag2N_g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Matt Fleming <matt@codeblueprint.co.uk>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, "linux@roeck-us.net" <linux@roeck-us.net>, Will Deacon <will.deacon@arm.com>, "Yu, Fenghua" <fenghua.yu@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

Pj4gSSB3b3VsZG4ndCBiZSBhZHZlcnNlIHRvIHlvdSBtYWtpbmcgYW4gYXNtL2Vhcmx5X2lvcmVt
YXAuaCBmaWxlDQo+PiBmb3IgaWE2NA0KPj4NCj4NCj4gSG93IGFib3V0IGFuIGFzbS9lZmkuaD8g
QSBsb3Qgb2YgdGhlIEVGSSBzb3VyY2UgZmlsZXMgaW5jbHVkZSBib3RoDQo+IGxpbnV4L2VmaS5o
IGFuZCBhc20vZWZpLmgsIHNvIGl0IHdvdWxkIG1ha2Ugc2Vuc2UgdG8gaGF2ZSBvbmUgb24gaWE2
NA0KPiBhcyB3ZWxsDQoNClBlcmhhcHMuICBJZiBJIGp1c3QgZW5kIHVwIHdpdGggYW4gZW1wdHkg
PGFzbS9zb21ldGhpbmcuaD4gZmlsZSBqdXN0DQpzbyBpdCBjYW4gYmUgaW5jbHVkZWQgd2l0aG91
dCBtYWtpbmcgYW4gZXJyb3IgdGhhdCdzIGxlc3MgZGVzaXJhYmxlIHRoYW4NCmhhdmluZyBzb21l
dGhpbmcgcmVsZXZhbnQgaW4gdGhlIGZpbGUuDQoNCi1Ub255DQo