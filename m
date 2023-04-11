From: David Laight <David.Laight@ACULAB.COM>
Date: Tue, 11 Apr 2023 09:49:53 +0000
Subject: RE: [PATCH v4] Kconfig: introduce HAS_IOPORT option and select it as necessary
Message-Id: <49ccbda9fc44496ba5688616d25ce901@AcuMS.aculab.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230323163354.1454196-1-schnelle@linux.ibm.com>
 <248a41a536d5a3c9e81e8e865b34c5bf74cd36d4.camel@linux.ibm.com>
 <B1EC1AC7-6BB5-4B66-B171-24687C3CBFB3@zytor.com>
 <d8686aaf-f12e-446b-9a80-335bb4266a4d@app.fastmail.com>
 <ccff565cde1440b8bff92d96f94a32b5@AcuMS.aculab.com>
 <CAMuHMdWe+U3yOOfy+z19apZaT0q7WhrR2beR=t0Jkbd3ODYbyw@mail.gmail.com>
In-Reply-To: <CAMuHMdWe+U3yOOfy+z19apZaT0q7WhrR2beR=t0Jkbd3ODYbyw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Geert Uytterhoeven' <geert@linux-m68k.org>
Cc: Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Niklas
 Schnelle <schnelle@linux.ibm.com>, Richard Henderson <richard.henderson@linaro.org>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Huacai Chen <chenhuacai@kernel.org>, WANG Xuerui <kernel@xen0n.name>, Michal
 Simek <monstr@monstr.eu>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, "James E . J . Bottomley" <James.Bottomley@hansenpartnership.com>, Helge
 Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas
 Piggin <npiggin@gmail.com>, Christophe Leroy <christophe.leroy@csgroup.eu>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Yoshinori Sato <ysato@users.osdn.me>, Rich Felker <dalias@libc.org>, John Paul Adrian
 Glaubitz <glaubitz@physik.fu-berlin.de>, "David S . Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, "x86@kernel.org" <x86@kernel.org>, "linux-m68k@vger.kernel.org" <linux-m68k@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "Rafael J .
 Wysocki" <rafael@kernel.org>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, "linux-mips@vger.kernel.org" <linux-mips@vger.kernel.org>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, "linux-riscv@lists.infradead.org" <linux-riscv@lists.infradead.org>, Linux-Arch <linux-arch@vger.kernel.org>, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, Alan Stern <stern@rowland.harvard.edu>, =?utf-8?B?VXdlIEtsZWluZS1Lw7ZuaWc=?= <u.kleine-koenig@pengutronix.de>, "loongarch@lists.linux.dev" <loongarch@lists.linux.dev>, Bjorn Helgaas <bhelgaas@google.com>, Mauro
 Carvalho Chehab <mchehab@kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Arnd Bergmann <arnd@kernel.org>, "linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>, Greg
 Kroah-Hartman <gregkh@linuxfoundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-alpha@vger.kernel.org" <linux-alpha@vger.kernel.org>, Johannes Berg <johannes@sipsolutions.net>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>

RnJvbTogR2VlcnQgVXl0dGVyaG9ldmVuDQo+IFNlbnQ6IDExIEFwcmlsIDIwMjMgMDk6NTANCj4g
DQo+IEhpIERhdmlkLA0KPiANCj4gT24gV2VkLCBBcHIgNSwgMjAyMyBhdCAxMTozN+KAr1BNIERh
dmlkIExhaWdodCA8RGF2aWQuTGFpZ2h0QGFjdWxhYi5jb20+IHdyb3RlOg0KPiA+IEZyb206IExp
bnV4cHBjLWRldiBBcm5kIEJlcmdtYW5uDQo+ID4gPiBTZW50OiAwNSBBcHJpbCAyMDIzIDIxOjMy
DQo+ID4gPg0KPiA+ID4gT24gV2VkLCBBcHIgNSwgMjAyMywgYXQgMjI6MDAsIEguIFBldGVyIEFu
dmluIHdyb3RlOg0KPiA+ID4gPiBPbiBBcHJpbCA1LCAyMDIzIDg6MTI6MzggQU0gUERULCBOaWts
YXMgU2NobmVsbGUgPHNjaG5lbGxlQGxpbnV4LmlibS5jb20+IHdyb3RlOg0KPiA+ID4gPj5PbiBU
aHUsIDIwMjMtMDMtMjMgYXQgMTc6MzMgKzAxMDAsIE5pa2xhcyBTY2huZWxsZSB3cm90ZToNCj4g
PiA+ID4+PiBXZSBpbnRyb2R1Y2UgYSBuZXcgSEFTX0lPUE9SVCBLY29uZmlnIG9wdGlvbiB0byBp
bmRpY2F0ZSBzdXBwb3J0IGZvciBJL08NCj4gPiA+ID4+PiBQb3J0IGFjY2Vzcy4gSW4gYSBmdXR1
cmUgcGF0Y2ggSEFTX0lPUE9SVD1uIHdpbGwgZGlzYWJsZSBjb21waWxhdGlvbiBvZg0KPiA+ID4g
Pj4+IHRoZSBJL08gYWNjZXNzb3IgZnVuY3Rpb25zIGluYigpL291dGIoKSBhbmQgZnJpZW5kcyBv
biBhcmNoaXRlY3R1cmVzDQo+ID4gPiA+Pj4gd2hpY2ggY2FuIG5vdCBtZWFuaW5nZnVsbHkgc3Vw
cG9ydCBsZWdhY3kgSS9PIHNwYWNlcyBzdWNoIGFzIHMzOTAuDQo+ID4gPiA+Pj4gPj4NCj4gPiA+
ID4+R2VudGxlIHBpbmcuIEFzIGZhciBhcyBJIGNhbiB0ZWxsIHRoaXMgaGFzbid0IGJlZW4gcGlj
a2VkIHRvIGFueSB0cmVlDQo+ID4gPiA+PnNwIGZhciBidXQgYWxzbyBoYXNuJ3Qgc2VlbiBjb21w
bGFpbnMgc28gSSdtIHdvbmRlcmluZyBpZiBJIHNob3VsZCBzZW5kDQo+ID4gPiA+PmEgbmV3IHZl
cnNpb24gb2YgdGhlIGNvbWJpbmVkIHNlcmllcyBvZiB0aGlzIHBhdGNoIHBsdXMgdGhlIGFkZGVk
DQo+ID4gPiA+PkhBU19JT1BPUlQgZGVwZW5kZW5jaWVzIHBlciBzdWJzeXN0ZW0gb3Igd2FpdCB1
bnRpbCB0aGlzIGlzIHBpY2tlZCB1cC4NCj4gPiA+ID4NCj4gPiA+ID4gWW91IG5lZWQgdGhpcyBv
biBhIHN5c3RlbSBzdXBwb3J0aW5nIG5vdCBqdXN0IElTQSBidXQgYWxzbyBQQ0kuDQo+ID4gPiA+
DQo+ID4gPiA+IFR5cGljYWxseSBvbiBub24teDg2IGFyY2hpdGVjdHVyZXMgdGhpcyBpcyBzaW1w
bHkgbWFwcGVkIGludG8gYSBtZW1vcnkgd2luZG93Lg0KPiA+ID4NCj4gPiA+IEknbSBwcmV0dHkg
Y29uZmlkZW50IHRoYXQgdGhlIGxpc3QgaXMgY29ycmVjdCBoZXJlLCBhcyB0aGUgSEFTX0lPUE9S
VA0KPiA+ID4gc3ltYm9sIGlzIGVuYWJsZWQgZXhhY3RseSBmb3IgdGhlIGFyY2hpdGVjdHVyZXMg
dGhhdCBoYXZlIGEgd2F5IHRvDQo+ID4gPiBtYXAgdGhlIEkvTyBzcGFjZS4gUENJZSBnZW5lcmFs
bHkgd29ya3MgZmluZSB3aXRob3V0IEkvTyBzcGFjZSwgdGhlDQo+ID4gPiBvbmx5IGV4Y2VwdGlv
biBhcmUgZHJpdmVycyBmb3IgZGV2aWNlcyB0aGF0IHdlcmUgYXJvdW5kIGFzIGVhcmx5IFBDSS4N
Cj4gPg0KPiA+IElzbid0IHRoZXJlIGEgZGlmZmVyZW5jZSBiZXR3ZWVuIGNwdSB0aGF0IGhhdmUg
aW5iKCkvb3V0YigpIChwcm9iYWJseQ0KPiA+IG9ubHkgeDg2PykgYW5kIGFyY2hpdGVjdHVyZXMg
KHdlbGwgY29tcHV0ZXIgZGVzaWducykgdGhhdCBjYW4gZ2VuZXJhdGUNCj4gPiBQQ0kgJ0kvTycg
Y3ljbGVzIGJ5IHNvbWUgbWVhbnMuDQo+ID4gSXQgaXNuJ3QgZXZlbiBqdXN0IFBDSSBJL08gY3lj
bGVzLCBJJ3ZlIHVzZWQgYW4gQVJNIGNwdSAoU0ExMTAwKQ0KPiA+IHRoYXQgbWFwcGVkIGEgY2h1
Y2sgb2YgcGh5c2ljYWwgYWRkcmVzcyBzcGFjZSBvbnRvIFBDTUNJQSBJL08gY3ljbGVzLg0KPiA+
DQo+ID4gSWYgdGhlIGhhcmR3YXJlIGNhbiBtYXAgYSBQQ0kgJ0lPJyBiYXIgaW50byBub3JtYWwg
a2VybmVsIGFkZHJlc3MNCj4gPiBzcGFjZSB0aGVuIHRoZSBiYXIgYW5kIGFjY2Vzc2VzIGNhbiBi
ZSB0cmVhdGVkIGV4YWN0bHkgbGlrZSBhIG1lbW9yeSBiYXIuDQo+ID4gVGhpcyBwcm9iYWJseSBs
ZWF2ZXMgeDg2IGFzIHRoZSBvdXRsaWVyIHdoZXJlIHlvdSBuZWVkIChJSVJDKSBpb19yZWFkbCgp
DQo+ID4gYW5kIGZyaWVuZHMgdGhhdCBjYW4gZ2VuZXJhdGUgaW4vb3V0IGluc3RydWN0aW9ucyBm
b3IgdGhvc2UgYWNjZXNzZXMuDQo+ID4NCj4gPiBUaGVyZSBhcmUgYWxzbyBhbGwgdGhlIHg4NiBJ
U0EgZGV2aWNlcyB3aGljaCBuZWVkIGluL291dCBpbnN0cnVjdGlvbnMuDQo+ID4gQnV0ICh3aXRo
IHRoZSBsaWtlbHkgZXhjZXB0aW9uIG9mIHRoZSBVQVJUKSB0aGV5IGFyZSBwcmV0dHkgbXVjaA0K
PiA+IHBsYXRmb3JtIHNwZWNpZmljLg0KPiA+DQo+ID4gU28sIHRvIG15IG1pbmQgYXQgbGVhc3Qs
IEhBU19JT1BPUlQgaXMganVzdCB0aGUgd3JvbmcgcXVlc3Rpb24uDQo+IA0KPiBOb3QgYWxsIFBD
SSBjb250cm9sbGVycyBzdXBwb3J0IG1hcHBpbmcgdGhlIEkvTyBiYXIgaW4gTU1JTyBzcGFjZSwg
c28NCj4gaW4gZ2VuZXJhbCB5b3UgY2Fubm90IHNheSB0aGF0IENPTkZJR19QQ0k9eSBtZWFucyBD
T05GSUdfSEFTX0lPUE9SVD15Lg0KDQpCdXQgYSBDT05GSUdfSEFTX1BDSV9JTz15IHdvdWxkIGlt
cGx5IENPTkZJR19IQVNfSU9QT1JUPXkuDQpJdCBpcyB0aGUgZm9ybWVyIHRoYXQgaXMgbW9yZSBp
bnRlcmVzdGluZyBmb3IgZHJpdmVyIHN1cHBvcnQuDQoNCglEYXZpZA0KDQotDQpSZWdpc3RlcmVk
IEFkZHJlc3MgTGFrZXNpZGUsIEJyYW1sZXkgUm9hZCwgTW91bnQgRmFybSwgTWlsdG9uIEtleW5l
cywgTUsxIDFQVCwgVUsNClJlZ2lzdHJhdGlvbiBObzogMTM5NzM4NiAoV2FsZXMpDQo
