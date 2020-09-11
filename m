From: Christoph Hellwig <hch@lst.de>
Date: Fri, 11 Sep 2020 07:09:50 +0000
Subject: Re: [PATCH 04/12] dma-mapping: fix DMA_OPS dependencies
Message-Id: <20200911070950.GB22394@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200908164758.3177341-1-hch@lst.de> <20200908164758.3177341-5-hch@lst.de> <1e3c7094-62da-6e8c-0a41-0bc63dd3db68@arm.com>
In-Reply-To: <1e3c7094-62da-6e8c-0a41-0bc63dd3db68@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="macroman"
Content-Transfer-Encoding: base64
To: Robin Murphy <robin.murphy@arm.com>
Cc: Christoph Hellwig <hch@lst.de>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, iommu@lists.linux-foundation.org, Tomasz Figa <tfiga@chromium.org>, Joerg Roedel <joro@8bytes.org>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org

T24gVGh1LCBTZXAgMTAsIDIwMjAgYXQgMDE6NTU6MzdQTSArMDEwMCwgUm9iaW4gTXVycGh5IHdy
b3RlOgo+IEFGQUlDUyBhbGwgdGhyZWUgb2YgdGhlc2UgYnVzIGRyaXZlcnMgYXJlIG9ubHkgcHJv
eHlpbmcgYSBzdHJ1Y3QgCj4gZG1hX21hcF9vcHMgKiBwb2ludGVyIGFyb3VuZCwgc28gaWYgdGhl
eSB1c2VkIHRoZSBzZXRfZG1hX29wcygpIGhlbHBlciB0aGV5IAo+IHNob3VsZG4ndCBldmVuIG5l
ZWQgdGhlc2Ugc2VsZWN0cyBhdCBhbGwuIE9ubHkgSU5URUxfTUlDX0hPU1QgYXBwZWFycyB0byAK
PiBoYXZlIGEgbG9naWNhbCBkZXBlbmRlbmN5IG9uIERNQV9PUFMgZm9yIGFjdHVhbCBmdW5jdGlv
bmFsaXR5Lgo+Cj4gSG93ZXZlciwgSSBoYXZlIGEgdmFndWUgZmVlbGluZyB5b3UgbWlnaHQgbm90
IGJlIGZvbmQgb2YgdGhvc2UgZG1hX29wcyAKPiBoZWxwZXJzLCBhbmQgSSBoYXZlIG5vIGdyZWF0
IG9iamVjdGlvbiB0byB0aGlzIG9uZS1saW5lciBhcy1pcywgc28gKG1vZHVsbyAKPiB0aGUgY291
cGxlIG9mIGNvbW1pdCBtZXNzYWdlIHR5cG9zKSwKClRoZSBwcm9ibGVtIHdpdGggdGhlc2UgaW5o
ZXLRlnRhbmNlcyBpcyB0aGF0IHRoZXkgZG9uJ3QgYWN0dWFsbHkgd29yawpmb3IgdGhlIGdlbmVy
YWwgY2FzZS4gIFlvdSdkIGFsc28gbmVlZCB0byBpbmhlcml0eSB0aGluZ3MgbGlrZSB0aGUKZG1h
IHJhbmdlcywgdGhlIGJ1cyBsaW1pdHMsIGV0YywgZXRjLiAgU28gd2UgbmVlZCB0byBraWxsIHRo
ZW0gaW5zdGVhZC4KVGhhdCB3aG9sZSBtaWMvdm9wIGNhc2UgaXMgZXZlbiB3b3JzZSB0aGFuIHRo
YXQgd2l0aCBpdCdzIHdlaXJkIHNldApvZiBjaGFpbmVkIGRtYSBvcHMgdGhhdCBzZWVtcyB0byBp
bXBsZW1lbnQgc29tZSBraW5kIG9mIGRldmljZSBzaWRlCmlvbW11IHRoYXQgaXNuJ3QgaW4gc2Nv
cGUgZm9yIHRoZSBETUEgQVBJIGF0IGFsbC4=
