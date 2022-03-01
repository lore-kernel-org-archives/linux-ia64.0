From: Andrew Cooper <Andrew.Cooper3@citrix.com>
Date: Tue, 01 Mar 2022 11:39:29 +0000
Subject: Re: [PATCH 08/12] x86: centralize setting SWIOTLB_FORCE when guest memory encryption is enabled
Message-Id: <8e623a11-d809-4fab-401c-2ce609a9fc14@citrix.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220301105311.885699-1-hch@lst.de>
 <20220301105311.885699-9-hch@lst.de>
In-Reply-To: <20220301105311.885699-9-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>
Cc: "x86@kernel.org" <x86@kernel.org>, Anshuman Khandual <anshuman.khandual@arm.com>, Tom Lendacky <thomas.lendacky@amd.com>, Konrad
 Rzeszutek Wilk <konrad.wilk@oracle.com>, Stefano Stabellini <sstabellini@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Joerg Roedel <joro@8bytes.org>, David
 Woodhouse <dwmw2@infradead.org>, Lu Baolu <baolu.lu@linux.intel.com>, Robin
 Murphy <robin.murphy@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-mips@vger.kernel.org" <linux-mips@vger.kernel.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "linux-riscv@lists.infradead.org" <linux-riscv@lists.infradead.org>, "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, "linux-hyperv@vger.kernel.org" <linux-hyperv@vger.kernel.org>, "tboot-devel@lists.sourceforge.net" <tboot-devel@lists.sourceforge.net>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>

T24gMDEvMDMvMjAyMiAxMDo1MywgQ2hyaXN0b3BoIEhlbGx3aWcgd3JvdGU6DQo+IGRpZmYgLS1n
aXQgYS9hcmNoL3g4Ni9rZXJuZWwvcGNpLWRtYS5jIGIvYXJjaC94ODYva2VybmVsL3BjaS1kbWEu
Yw0KPiBpbmRleCAyYWMwZWY5YzJmYjc2Li43YWI3MDAyNzU4Mzk2IDEwMDY0NA0KPiAtLS0gYS9h
cmNoL3g4Ni9rZXJuZWwvcGNpLWRtYS5jDQo+ICsrKyBiL2FyY2gveDg2L2tlcm5lbC9wY2ktZG1h
LmMNCj4gQEAgLTUzLDYgKzUzLDEzIEBAIHN0YXRpYyB2b2lkIF9faW5pdCBwY2lfc3dpb3RsYl9k
ZXRlY3Qodm9pZCkNCj4gIAlpZiAoY2NfcGxhdGZvcm1faGFzKENDX0FUVFJfSE9TVF9NRU1fRU5D
UllQVCkpDQo+ICAJCXg4Nl9zd2lvdGxiX2VuYWJsZSA9IHRydWU7DQo+ICANCj4gKwkvKg0KPiAr
CSAqIEd1ZXN0IHdpdGggZ3Vlc3QgbWVtb3J5IGVuY3J5cHRpb24gbXVzdCBhbHdheXMgZG8gSS9P
IHRocm91Z2ggYQ0KPiArCSAqIGJvdW5jZSBidWZmZXIgYXMgdGhlIGh5cGVydmlzb3IgY2FuJ3Qg
YWNjZXNzIGFyYml0cmFyeSBWTSBtZW1vcnkuDQoNClRoaXMgaXNuJ3QgcmVhbGx5ICJtdXN0Ii7C
oCBUaGUgZ3Vlc3QgaXMgcGVyZmVjdGx5IGNhcGFibGUgb2Ygc2hhcmluZw0KbWVtb3J5IHdpdGgg
dGhlIGh5cGVydmlzb3IuDQoNCkl0J3MganVzdCB0aGF0IGZvciBub3csIGJvdW5jZSBidWZmZXJp
bmcgaXMgYWxsZWdlZGx5IGZhc3RlciwgYW5kIHRoZQ0Kc2ltcGxlIHdheSBvZiBnZXR0aW5nIGl0
IHdvcmtpbmcuDQoNCn5BbmRyZXcNCg=
