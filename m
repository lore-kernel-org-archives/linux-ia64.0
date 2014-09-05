From: wangyijing <wangyijing0307@gmail.com>
Date: Fri, 05 Sep 2014 11:30:01 +0000
Subject: Re: [PATCH v1 09/21] Irq_remapping/MSI: Use MSI chip framework to configure MSI/MSI-X irq
Message-Id: <58C2E84C-7080-4FDA-8684-5D0B2DAD7C20@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1409911806-10519-1-git-send-email-wangyijing@huawei.com> <1409911806-10519-10-git-send-email-wangyijing@huawei.com> <540993B3.1000701@cogentembedded.com>
In-Reply-To: <540993B3.1000701@cogentembedded.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Cc: Yijing Wang <wangyijing@huawei.com>, Bjorn Helgaas <bhelgaas@google.com>, Xinwei Hu <huxinwei@huawei.com>, Wuyun <wuyun.wu@huawei.com>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Russell King <linux@arm.linux.org.uk>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "arnab.basu@freescale.com" <arnab.basu@freescale.com>, "Bharat.Bhushan@freescale.com" <Bharat.Bhushan@freescale.com>, "x86@kernel.org" <x86@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>, Joerg Roedel <joro@8bytes.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "linux-mips@linux-mips.org" <linux-mips@linux-mips.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, Sebastian Ott <sebott@linux.vnet.ibm.com>, Tony Luck <tony.luck@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, Chris Metcalf <cmetcalf@tilera.com>, Ralf Baechle <ralf@linux-mips.org>

Cj4g1NogMjAxNMTqOdTCNcjVo6wxODo0MqOsU2VyZ2VpIFNodHlseW92IDxzZXJnZWkuc2h0eWx5
b3ZAY29nZW50ZW1iZWRkZWQuY29tPiDQtLXAo7oKPiAKPiBIZWxsby4KPiAKPj4gT24gOS81LzIw
MTQgMjowOSBQTSwgWWlqaW5nIFdhbmcgd3JvdGU6Cj4+IAo+PiBVc2UgTVNJIGNoaXAgZnJhbWV3
b3JrIGluc3RlYWQgb2YgYXJjaCBNU0kgZnVuY3Rpb25zIHRvIGNvbmZpZ3VyZQo+PiBNU0kvTVNJ
LVggaXJxLiBTbyB3ZSBjYW4gbWFuYWdlIE1TSS9NU0ktWCBpcnEgaW4gYSB1bmlmaWVkIGZyYW1l
d29yay4KPiAKPj4gU2lnbmVkLW9mZi1ieTogWWlqaW5nIFdhbmcgPHdhbmd5aWppbmdAaHVhd2Vp
LmNvbT4KPj4gLS0tCj4+ICBkcml2ZXJzL2lvbW11L2lycV9yZW1hcHBpbmcuYyB8ICAgIDggKysr
KysrKy0KPj4gIDEgZmlsZXMgY2hhbmdlZCwgNyBpbnNlcnRpb25zKCspLCAxIGRlbGV0aW9ucygt
KQo+IAo+PiBkaWZmIC0tZ2l0IGEvZHJpdmVycy9pb21tdS9pcnFfcmVtYXBwaW5nLmMgYi9kcml2
ZXJzL2lvbW11L2lycV9yZW1hcHBpbmcuYwo+PiBpbmRleCAzM2M0Mzk1Li5lNzUwMjZlIDEwMDY0
NAo+PiAtLS0gYS9kcml2ZXJzL2lvbW11L2lycV9yZW1hcHBpbmcuYwo+PiArKysgYi9kcml2ZXJz
L2lvbW11L2lycV9yZW1hcHBpbmcuYwo+IFsuLi5dCj4+IEBAIC0xNjUsOSArMTcwLDEwIEBAIHN0
YXRpYyB2b2lkIF9faW5pdCBpcnFfcmVtYXBwaW5nX21vZGlmeV94ODZfb3BzKHZvaWQpCj4+ICAg
ICAgeDg2X2lvX2FwaWNfb3BzLnNldF9hZmZpbml0eSAgICA9IHNldF9yZW1hcHBlZF9pcnFfYWZm
aW5pdHk7Cj4+ICAgICAgeDg2X2lvX2FwaWNfb3BzLnNldHVwX2VudHJ5ICAgID0gc2V0dXBfaW9h
cGljX3JlbWFwcGVkX2VudHJ5Owo+PiAgICAgIHg4Nl9pb19hcGljX29wcy5lb2lfaW9hcGljX3Bp
biAgICA9IGVvaV9pb2FwaWNfcGluX3JlbWFwcGVkOwo+PiAtICAgIHg4Nl9tc2kuc2V0dXBfbXNp
X2lycXMgICAgICAgID0gaXJxX3JlbWFwcGluZ19zZXR1cF9tc2lfaXJxczsKPj4gKyAgICB4ODZf
bXNpLnNldHVwX21zaV9pcnFzICAgICAgICAgID0gaXJxX3JlbWFwcGluZ19zZXR1cF9tc2lfaXJx
czsKPiAKPiAgIEFGQUlDUywgdGhpcyBjaGFuZ2Ugb25seSBjb252ZXJ0cyB0YWJzIHRvIHNwYWNl
cywgc28gbm90IG5lZWRlZCBhdCBhbGwuCgpXaWxsIHVwZGF0ZSwgIHRoYW5rcy4KCj4gCj4+ICAg
ICAgeDg2X21zaS5zZXR1cF9ocGV0X21zaSAgICAgICAgPSBzZXR1cF9ocGV0X21zaV9yZW1hcHBl
ZDsKPj4gICAgICB4ODZfbXNpLmNvbXBvc2VfbXNpX21zZyAgICAgICAgPSBjb21wb3NlX3JlbWFw
cGVkX21zaV9tc2c7Cj4+ICsgICAgeDg2X21zaV9jaGlwID0gJnJlbWFwX21zaV9jaGlwOwo+IAo+
ICAgUGxlYXNlIGFsaWduID0gd2l0aCB0aGUgcmVzdCBvZiBhc3NpZ25tZW50cy4KCk9rLgoKVGhh
bmtzIQpZaWppbmcuCgo+IAo+IFdCUiwgU2VyZ2VpCj4gCj4gLS0KPiBUbyB1bnN1YnNjcmliZSBm
cm9tIHRoaXMgbGlzdDogc2VuZCB0aGUgbGluZSAidW5zdWJzY3JpYmUgbGludXgtcGNpIiBpbgo+
IHRoZSBib2R5IG9mIGEgbWVzc2FnZSB0byBtYWpvcmRvbW9Admdlci5rZXJuZWwub3JnCj4gTW9y
ZSBtYWpvcmRvbW8gaW5mbyBhdCAgaHR0cDovL3ZnZXIua2VybmVsLm9yZy9tYWpvcmRvbW8taW5m
by5odG1sCi0tClRvIHVuc3Vic2NyaWJlIGZyb20gdGhpcyBsaXN0OiBzZW5kIHRoZSBsaW5lICJ1
bnN1YnNjcmliZSBsaW51eC1pYTY0IiBpbgp0aGUgYm9keSBvZiBhIG1lc3NhZ2UgdG8gbWFqb3Jk
b21vQHZnZXIua2VybmVsLm9yZwpNb3JlIG1ham9yZG9tbyBpbmZvIGF0ICBodHRwOi8vdmdlci5r
ZXJuZWwub3JnL21ham9yZG9tby1pbmZvLmh0bWw=
