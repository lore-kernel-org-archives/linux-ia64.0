From: "Lendacky, Thomas" <Thomas.Lendacky@amd.com>
Date: Tue, 20 Aug 2019 21:18:03 +0000
Subject: Re: [PATCH 10/11] iommu: Disable passthrough mode when SME is active
Message-Id: <82e00ce5-df71-5b71-cf5d-3de86aa0a1e8@amd.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190819132256.14436-1-joro@8bytes.org>
 <20190819132256.14436-11-joro@8bytes.org>
In-Reply-To: <20190819132256.14436-11-joro@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joerg Roedel <joro@8bytes.org>
Cc: "corbet@lwn.net" <corbet@lwn.net>, "tony.luck@intel.com" <tony.luck@intel.com>, "fenghua.yu@intel.com" <fenghua.yu@intel.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "mingo@redhat.com" <mingo@redhat.com>, "bp@alien8.de" <bp@alien8.de>, "hpa@zytor.com" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Suthikulpanit, Suravee" <Suravee.Suthikulpanit@amd.com>, Joerg Roedel <jroedel@suse.de>

T24gOC8xOS8xOSA4OjIyIEFNLCBKb2VyZyBSb2VkZWwgd3JvdGU6DQo+IEZyb206IEpvZXJnIFJv
ZWRlbCA8anJvZWRlbEBzdXNlLmRlPg0KPiANCj4gVXNpbmcgUGFzc3Rocm91Z2ggbW9kZSB3aGVu
IFNNRSBpcyBhY3RpdmUgY2F1c2VzIGNlcnRhaW4NCj4gZGV2aWNlcyB0byB1c2UgdGhlIFNXSU9U
TEIgYm91bmNlIGJ1ZmZlci4gVGhlIGJvdW5jZSBidWZmZXINCj4gY29kZSBoYXMgYW4gdXBwZXIg
bGltaXQgb2YgMjU2a2IgZm9yIHRoZSBzaXplIG9mIERNQQ0KPiBhbGxvY2F0aW9ucywgd2hpY2gg
aXMgdG9vIHNtYWxsIGZvciBjZXJ0YWluIGRldmljZXMgYW5kDQo+IGNhdXNlcyB0aGVtIHRvIGZh
aWwuDQo+IA0KPiBXaXRoIHRoaXMgcGF0Y2ggd2UgZW5hYmxlIElPTU1VIGJ5IGRlZmF1bHQgd2hl
biBTTUUgaXMNCj4gYWN0aXZlIGluIHRoZSBzeXN0ZW0sIG1ha2luZyB0aGUgZGVmYXVsdCBjb25m
aWd1cmF0aW9uIHdvcmsNCj4gZm9yIG1vcmUgc3lzdGVtcyB0aGFuIGl0IGRvZXMgbm93Lg0KPiAN
Cj4gVXNlcnMgdGhhdCBkb24ndCB3YW50IElPTU1VcyB0byBiZSBlbmFibGVkIHN0aWxsIGNhbiBk
aXNhYmxlDQo+IHRoZW0gd2l0aCBrZXJuZWwgcGFyYW1ldGVycy4NCj4gDQo+IFNpZ25lZC1vZmYt
Ynk6IEpvZXJnIFJvZWRlbCA8anJvZWRlbEBzdXNlLmRlPg0KDQpSZXZpZXdlZC1ieTogVG9tIExl
bmRhY2t5IDx0aG9tYXMubGVuZGFja3lAYW1kLmNvbT4NClRlc3RlZC1ieTogVG9tIExlbmRhY2t5
IDx0aG9tYXMubGVuZGFja3lAYW1kLmNvbT4NCg0KPiAtLS0NCj4gIGRyaXZlcnMvaW9tbXUvaW9t
bXUuYyB8IDUgKysrKysNCj4gIDEgZmlsZSBjaGFuZ2VkLCA1IGluc2VydGlvbnMoKykNCj4gDQo+
IGRpZmYgLS1naXQgYS9kcml2ZXJzL2lvbW11L2lvbW11LmMgYi9kcml2ZXJzL2lvbW11L2lvbW11
LmMNCj4gaW5kZXggMDE3NTlkNGFjNzBiLi5lYzE4Yzk2MzBlOTMgMTAwNjQ0DQo+IC0tLSBhL2Ry
aXZlcnMvaW9tbXUvaW9tbXUuYw0KPiArKysgYi9kcml2ZXJzL2lvbW11L2lvbW11LmMNCj4gQEAg
LTExOSw2ICsxMTksMTEgQEAgc3RhdGljIGludCBfX2luaXQgaW9tbXVfc3Vic3lzX2luaXQodm9p
ZCkNCj4gIAkJCWlvbW11X3NldF9kZWZhdWx0X3Bhc3N0aHJvdWdoKGZhbHNlKTsNCj4gIAkJZWxz
ZQ0KPiAgCQkJaW9tbXVfc2V0X2RlZmF1bHRfdHJhbnNsYXRlZChmYWxzZSk7DQo+ICsNCj4gKwkJ
aWYgKGlvbW11X2RlZmF1bHRfcGFzc3Rocm91Z2goKSAmJiBzbWVfYWN0aXZlKCkpIHsNCj4gKwkJ
CXByX2luZm8oIlNNRSBkZXRlY3RlZCAtIERpc2FibGluZyBkZWZhdWx0IElPTU1VIFBhc3N0aHJv
dWdoXG4iKTsNCj4gKwkJCWlvbW11X3NldF9kZWZhdWx0X3RyYW5zbGF0ZWQoZmFsc2UpOw0KPiAr
CQl9DQo+ICAJfQ0KPiAgDQo+ICAJcHJfaW5mbygiRGVmYXVsdCBkb21haW4gdHlwZTogJXMgJXNc
biIsDQo+IA0K
