From: "Moore, Robert" <robert.moore@intel.com>
Date: Thu, 31 Mar 2022 19:27:29 +0000
Subject: RE: [PATCH 05/22] acpica: Replace comments with C99 initializers
Message-Id: <BYAPR11MB3256D71C02271CD434959E0187E19@BYAPR11MB3256.namprd11.prod.outlook.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220326165909.506926-1-benni@stuerz.xyz>
 <20220326165909.506926-5-benni@stuerz.xyz>
 <CAHp75VeTXMAueQc_c0Ryj5+a8PrJ7gk-arugiNnxtAm03x7XTg@mail.gmail.com>
In-Reply-To: <CAHp75VeTXMAueQc_c0Ryj5+a8PrJ7gk-arugiNnxtAm03x7XTg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andy Shevchenko <andy.shevchenko@gmail.com>, =?utf-8?B?QmVuamFtaW4gU3TDvHJ6?= <benni@stuerz.xyz>
Cc: Andrew Lunn <andrew@lunn.ch>, Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>, Gregory Clement <gregory.clement@bootlin.com>, Russell King - ARM Linux <linux@armlinux.org.uk>, "linux@simtec.co.uk" <linux@simtec.co.uk>, Krzysztof Kozlowski <krzk@kernel.org>, Alim Akhtar <alim.akhtar@samsung.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, "Wysocki, Rafael J" <rafael.j.wysocki@intel.com>, Len Brown <lenb@kernel.org>, "3chas3@gmail.com" <3chas3@gmail.com>, Harald Welte <laforge@gnumonks.org>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Mauro Carvalho Chehab <mchehab@kernel.org>, "Luck, Tony" <tony.luck@intel.com>, James Morse <james.morse@arm.com>, Robert Richter <rric@kernel.org>, Linus Walleij <linus.walleij@linaro.org>, Bartosz Golaszewski <brgl@bgdev.pl>, "mike.marciniszyn@cornelisnetworks.com" <mike.marciniszyn@cornelisnetworks.com>, "dennis.dalessandro@cornelisnetworks.com" <dennis.dalessandro@cornelisnetworks.com>, Jason Gunthorpe <jgg@ziepe.ca>, =?utf-8?B?UGFsaSBSb2jDoXI=?= <pali@kernel.org>, Dmitry Torokhov <dmitry.torokhov@gmail.com>, Karsten Keil <isdn@linux-pingi.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Frederic Barrat <fbarrat@linux.ibm.com>, Andrew Donnellan <ajd@linux.ibm.com>, "David S. Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, Nicolas Pitre <nico@fluxnic.net>, Loic Poulain <loic.poulain@linaro.org>, Kalle Valo <kvalo@kernel.org>, Ping-Ke Shih <pkshih@realtek.com>, Bjorn Helgaas <bhelgaas@google.com>, linux-arm Mailing List <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Samsung SOC <linux-samsung-soc@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, "open list:ACPI COMPONENT ARCHITECTURE (ACPICA)" <devel@acpica.org>, "linux-atm-general@lists.sourceforge.net" <linux-atm-general@lists.sourceforge.net>, netdev <netdev@vger.kernel.org>, "linux-edac@vger.kernel.org" <linux-edac@vger.kernel.org>, "open list:GPIO SUBSYSTEM" <linux-gpio@vger.kernel.org>, "open list:HFI1 DRIVER" <linux-rdma@vger.kernel.org>, linux-input <linux-input@vger.kernel.org>, "open list:LINUX FOR POWERPC PA SEMI PWRFICIENT" <linuxppc-dev@lists.ozlabs.org>, "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>, "wcn36xx@lists.infradead.org" <wcn36xx@lists.infradead.org>, "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>

DQoNCi0tLS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0tDQpGcm9tOiBBbmR5IFNoZXZjaGVua28gPGFu
ZHkuc2hldmNoZW5rb0BnbWFpbC5jb20+IA0KU2VudDogU3VuZGF5LCBNYXJjaCAyNywgMjAyMiAx
OjAwIFBNDQpUbzogQmVuamFtaW4gU3TDvHJ6IDxiZW5uaUBzdHVlcnoueHl6Pg0KQ2M6IEFuZHJl
dyBMdW5uIDxhbmRyZXdAbHVubi5jaD47IFNlYmFzdGlhbiBIZXNzZWxiYXJ0aCA8c2ViYXN0aWFu
Lmhlc3NlbGJhcnRoQGdtYWlsLmNvbT47IEdyZWdvcnkgQ2xlbWVudCA8Z3JlZ29yeS5jbGVtZW50
QGJvb3RsaW4uY29tPjsgUnVzc2VsbCBLaW5nIC0gQVJNIExpbnV4IDxsaW51eEBhcm1saW51eC5v
cmcudWs+OyBsaW51eEBzaW10ZWMuY28udWs7IEtyenlzenRvZiBLb3psb3dza2kgPGtyemtAa2Vy
bmVsLm9yZz47IEFsaW0gQWtodGFyIDxhbGltLmFraHRhckBzYW1zdW5nLmNvbT47IFRob21hcyBH
bGVpeG5lciA8dGdseEBsaW51dHJvbml4LmRlPjsgSW5nbyBNb2xuYXIgPG1pbmdvQHJlZGhhdC5j
b20+OyBCb3Jpc2xhdiBQZXRrb3YgPGJwQGFsaWVuOC5kZT47IERhdmUgSGFuc2VuIDxkYXZlLmhh
bnNlbkBsaW51eC5pbnRlbC5jb20+OyBILiBQZXRlciBBbnZpbiA8aHBhQHp5dG9yLmNvbT47IE1v
b3JlLCBSb2JlcnQgPHJvYmVydC5tb29yZUBpbnRlbC5jb20+OyBXeXNvY2tpLCBSYWZhZWwgSiA8
cmFmYWVsLmoud3lzb2NraUBpbnRlbC5jb20+OyBMZW4gQnJvd24gPGxlbmJAa2VybmVsLm9yZz47
IDNjaGFzM0BnbWFpbC5jb207IEhhcmFsZCBXZWx0ZSA8bGFmb3JnZUBnbnVtb25rcy5vcmc+OyBB
cm5kIEJlcmdtYW5uIDxhcm5kQGFybmRiLmRlPjsgR3JlZyBLcm9haC1IYXJ0bWFuIDxncmVna2hA
bGludXhmb3VuZGF0aW9uLm9yZz47IE1hdXJvIENhcnZhbGhvIENoZWhhYiA8bWNoZWhhYkBrZXJu
ZWwub3JnPjsgTHVjaywgVG9ueSA8dG9ueS5sdWNrQGludGVsLmNvbT47IEphbWVzIE1vcnNlIDxq
YW1lcy5tb3JzZUBhcm0uY29tPjsgUm9iZXJ0IFJpY2h0ZXIgPHJyaWNAa2VybmVsLm9yZz47IExp
bnVzIFdhbGxlaWogPGxpbnVzLndhbGxlaWpAbGluYXJvLm9yZz47IEJhcnRvc3ogR29sYXN6ZXdz
a2kgPGJyZ2xAYmdkZXYucGw+OyBtaWtlLm1hcmNpbmlzenluQGNvcm5lbGlzbmV0d29ya3MuY29t
OyBkZW5uaXMuZGFsZXNzYW5kcm9AY29ybmVsaXNuZXR3b3Jrcy5jb207IEphc29uIEd1bnRob3Jw
ZSA8amdnQHppZXBlLmNhPjsgUGFsaSBSb2jDoXIgPHBhbGlAa2VybmVsLm9yZz47IERtaXRyeSBU
b3Jva2hvdiA8ZG1pdHJ5LnRvcm9raG92QGdtYWlsLmNvbT47IEthcnN0ZW4gS2VpbCA8aXNkbkBs
aW51eC1waW5naS5kZT47IEJlbmphbWluIEhlcnJlbnNjaG1pZHQgPGJlbmhAa2VybmVsLmNyYXNo
aW5nLm9yZz47IEZyZWRlcmljIEJhcnJhdCA8ZmJhcnJhdEBsaW51eC5pYm0uY29tPjsgQW5kcmV3
IERvbm5lbGxhbiA8YWpkQGxpbnV4LmlibS5jb20+OyBEYXZpZCBTLiBNaWxsZXIgPGRhdmVtQGRh
dmVtbG9mdC5uZXQ+OyBKYWt1YiBLaWNpbnNraSA8a3ViYUBrZXJuZWwub3JnPjsgUGFvbG8gQWJl
bmkgPHBhYmVuaUByZWRoYXQuY29tPjsgTmljb2xhcyBQaXRyZSA8bmljb0BmbHV4bmljLm5ldD47
IExvaWMgUG91bGFpbiA8bG9pYy5wb3VsYWluQGxpbmFyby5vcmc+OyBLYWxsZSBWYWxvIDxrdmFs
b0BrZXJuZWwub3JnPjsgUGluZy1LZSBTaGloIDxwa3NoaWhAcmVhbHRlay5jb20+OyBCam9ybiBI
ZWxnYWFzIDxiaGVsZ2Fhc0Bnb29nbGUuY29tPjsgbGludXgtYXJtIE1haWxpbmcgTGlzdCA8bGlu
dXgtYXJtLWtlcm5lbEBsaXN0cy5pbmZyYWRlYWQub3JnPjsgTGludXggS2VybmVsIE1haWxpbmcg
TGlzdCA8bGludXgta2VybmVsQHZnZXIua2VybmVsLm9yZz47IExpbnV4IFNhbXN1bmcgU09DIDxs
aW51eC1zYW1zdW5nLXNvY0B2Z2VyLmtlcm5lbC5vcmc+OyBsaW51eC1pYTY0QHZnZXIua2VybmVs
Lm9yZzsgQUNQSSBEZXZlbCBNYWxpbmcgTGlzdCA8bGludXgtYWNwaUB2Z2VyLmtlcm5lbC5vcmc+
OyBvcGVuIGxpc3Q6QUNQSSBDT01QT05FTlQgQVJDSElURUNUVVJFIChBQ1BJQ0EpIDxkZXZlbEBh
Y3BpY2Eub3JnPjsgbGludXgtYXRtLWdlbmVyYWxAbGlzdHMuc291cmNlZm9yZ2UubmV0OyBuZXRk
ZXYgPG5ldGRldkB2Z2VyLmtlcm5lbC5vcmc+OyBsaW51eC1lZGFjQHZnZXIua2VybmVsLm9yZzsg
b3BlbiBsaXN0OkdQSU8gU1VCU1lTVEVNIDxsaW51eC1ncGlvQHZnZXIua2VybmVsLm9yZz47IG9w
ZW4gbGlzdDpIRkkxIERSSVZFUiA8bGludXgtcmRtYUB2Z2VyLmtlcm5lbC5vcmc+OyBsaW51eC1p
bnB1dCA8bGludXgtaW5wdXRAdmdlci5rZXJuZWwub3JnPjsgb3BlbiBsaXN0OkxJTlVYIEZPUiBQ
T1dFUlBDIFBBIFNFTUkgUFdSRklDSUVOVCA8bGludXhwcGMtZGV2QGxpc3RzLm96bGFicy5vcmc+
OyBsaW51eC1tZWRpYUB2Z2VyLmtlcm5lbC5vcmc7IHdjbjM2eHhAbGlzdHMuaW5mcmFkZWFkLm9y
ZzsgbGludXgtd2lyZWxlc3NAdmdlci5rZXJuZWwub3JnOyBsaW51eC1wY2lAdmdlci5rZXJuZWwu
b3JnDQpTdWJqZWN0OiBSZTogW1BBVENIIDA1LzIyXSBhY3BpY2E6IFJlcGxhY2UgY29tbWVudHMg
d2l0aCBDOTkgaW5pdGlhbGl6ZXJzDQoNCk9uIFNhdCwgTWFyIDI2LCAyMDIyIGF0IDc6MzkgUE0g
QmVuamFtaW4gU3TDvHJ6IDxiZW5uaUBzdHVlcnoueHl6PiB3cm90ZToNCj4NCj4gVGhpcyByZXBs
YWNlcyBjb21tZW50cyB3aXRoIEM5OSdzIGRlc2lnbmF0ZWQgaW5pdGlhbGl6ZXJzIGJlY2F1c2Ug
dGhlIA0KPiBrZXJuZWwgc3VwcG9ydHMgdGhlbSBub3cuDQoNCkRvZXMgaXQgZm9sbG93IHRoZSBj
b252ZW50aW9ucyB3aGljaCBhcmUgYWNjZXB0ZWQgaW4gdGhlIEFDUEkgQ0EgcHJvamVjdD8NCg0K
Tm8sIGl0IGRvZXNuJ3QuIEFDUElDQSBtdXN0IHdvcmsgd2l0aCBtYW55IGNvbXBpbGVycywgc29t
ZSBvZiB3aGljaCBhcmUgcmF0aGVyIG9sZC4gU28sIHdlIGRvbid0IHN1cHBvcnQgdGhlc2UgaW5p
dGlhbGl6ZXJzLg0KQm9iDQoNCi0tDQpXaXRoIEJlc3QgUmVnYXJkcywNCkFuZHkgU2hldmNoZW5r
bw0K
