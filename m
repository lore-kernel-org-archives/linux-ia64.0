From: Christophe Leroy <christophe.leroy@csgroup.eu>
Date: Sun, 27 Feb 2022 18:15:23 +0000
Subject: Re: [PATCH 08/11] swiotlb: make the swiotlb_init interface more useful
Message-Id: <3f5c827f-8e91-baef-7114-784a0c65e298@csgroup.eu>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220227143055.335596-1-hch@lst.de>
 <20220227143055.335596-9-hch@lst.de>
In-Reply-To: <20220227143055.335596-9-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>
Cc: Juergen Gross <jgross@suse.com>, "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, "linux-hyperv@vger.kernel.org" <linux-hyperv@vger.kernel.org>, Stefano Stabellini <sstabellini@kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Anshuman Khandual <anshuman.khandual@arm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Robin Murphy <robin.murphy@arm.com>, Joerg Roedel <joro@8bytes.org>, "x86@kernel.org" <x86@kernel.org>, "linux-mips@vger.kernel.org" <linux-mips@vger.kernel.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "tboot-devel@lists.sourceforge.net" <tboot-devel@lists.sourceforge.net>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, David Woodhouse <dwmw2@infradead.org>, "linux-riscv@lists.infradead.org" <linux-riscv@lists.infradead.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Lu Baolu <baolu.lu@linux.intel.com>

DQoNCkxlIDI3LzAyLzIwMjIgw6AgMTU6MzAsIENocmlzdG9waCBIZWxsd2lnIGEgw6ljcml0wqA6
DQo+IFBhc3MgYSBib29sIHRvIHBhc3MgaWYgc3dpb3RsYiBuZWVkcyB0byBiZSBlbmFibGVkIGJh
c2VkIG9uIHRoZQ0KPiBhZGRyZXNzaW5nIG5lZWRzIGFuZCByZXBsYWNlIHRoZSB2ZXJib3NlIGFy
Z3VtZW50IHdpdGggYSBzZXQgb2YNCj4gZmxhZ3MsIGluY2x1ZGluZyBvbmUgdG8gZm9yY2UgZW5h
YmxlIGJvdW5jZSBidWZmZXJpbmcuDQo+IA0KPiBOb3RlIHRoYXQgdGhpcyBwYXRjaCByZW1vdmVz
IHRoZSBwb3NzaWJpbGl0eSB0byBmb3JjZSB4ZW4tc3dpb3RsYg0KPiB1c2UgdXNpbmcgc3dpb3Rs
Yj1mb3JjZSBvbiB0aGUgY29tbWFuZCBsaW5lIG9uIHg4NiAoYXJtIGFuZCBhcm02NA0KPiBuZXZl
ciBzdXBwb3J0ZWQgdGhhdCksIGJ1dCB0aGlzIGludGVyZmFjZSB3aWxsIGJlIHJlc3RvcmVkIHNo
b3J0bHkuDQo+IA0KPiBTaWduZWQtb2ZmLWJ5OiBDaHJpc3RvcGggSGVsbHdpZyA8aGNoQGxzdC5k
ZT4NCj4gLS0tDQo+ICAgYXJjaC9hcm0vbW0vaW5pdC5jICAgICAgICAgICAgICAgICAgICAgfCAg
NiArLS0tLQ0KPiAgIGFyY2gvYXJtNjQvbW0vaW5pdC5jICAgICAgICAgICAgICAgICAgIHwgIDYg
Ky0tLS0NCj4gICBhcmNoL2lhNjQvbW0vaW5pdC5jICAgICAgICAgICAgICAgICAgICB8ICA0ICst
LQ0KPiAgIGFyY2gvbWlwcy9jYXZpdW0tb2N0ZW9uL2RtYS1vY3Rlb24uYyAgIHwgIDIgKy0NCj4g
ICBhcmNoL21pcHMvbG9vbmdzb242NC9kbWEuYyAgICAgICAgICAgICB8ICAyICstDQo+ICAgYXJj
aC9taXBzL3NpYnl0ZS9jb21tb24vZG1hLmMgICAgICAgICAgfCAgMiArLQ0KPiAgIGFyY2gvcG93
ZXJwYy9pbmNsdWRlL2FzbS9zd2lvdGxiLmggICAgIHwgIDEgKw0KPiAgIGFyY2gvcG93ZXJwYy9t
bS9tZW0uYyAgICAgICAgICAgICAgICAgIHwgIDMgKystDQoNCmFyY2gvcG93ZXJwYy9tbS9tZW0u
bzooLnRvYysweDApOiB1bmRlZmluZWQgcmVmZXJlbmNlIHRvIGBwcGNfc3dpb3RsYl9mbGFncycN
Cm1ha2VbMV06ICoqKiBbdm1saW51eF0gRXJyb3IgMQ0KL2xpbnV4L01ha2VmaWxlOjExNTU6IHJl
Y2lwZSBmb3IgdGFyZ2V0ICd2bWxpbnV4JyBmYWlsZWQNCg0KDQo+ICAgYXJjaC9wb3dlcnBjL3Bs
YXRmb3Jtcy9wc2VyaWVzL3NldHVwLmMgfCAgMyAtLS0NCj4gICBhcmNoL3Jpc2N2L21tL2luaXQu
YyAgICAgICAgICAgICAgICAgICB8ICA4ICstLS0tLQ0KPiAgIGFyY2gvczM5MC9tbS9pbml0LmMg
ICAgICAgICAgICAgICAgICAgIHwgIDMgKy0tDQo+ICAgYXJjaC94ODYva2VybmVsL2NwdS9tc2h5
cGVydi5jICAgICAgICAgfCAgOCAtLS0tLS0NCj4gICBhcmNoL3g4Ni9rZXJuZWwvcGNpLWRtYS5j
ICAgICAgICAgICAgICB8IDE1ICsrKysrKy0tLS0tDQo+ICAgYXJjaC94ODYvbW0vbWVtX2VuY3J5
cHRfYW1kLmMgICAgICAgICAgfCAgMyAtLS0NCj4gICBkcml2ZXJzL3hlbi9zd2lvdGxiLXhlbi5j
ICAgICAgICAgICAgICB8ICA0ICstLQ0KPiAgIGluY2x1ZGUvbGludXgvc3dpb3RsYi5oICAgICAg
ICAgICAgICAgIHwgMTUgKysrKysrLS0tLS0NCj4gICBpbmNsdWRlL3RyYWNlL2V2ZW50cy9zd2lv
dGxiLmggICAgICAgICB8IDI5ICsrKysrKysrLS0tLS0tLS0tLS0tLQ0KPiAgIGtlcm5lbC9kbWEv
c3dpb3RsYi5jICAgICAgICAgICAgICAgICAgIHwgMzUgKysrKysrKysrKysrKystLS0tLS0tLS0t
LS0NCj4gICAxOCBmaWxlcyBjaGFuZ2VkLCA1NiBpbnNlcnRpb25zKCspLCA5MyBkZWxldGlvbnMo
LSkNCj4g
