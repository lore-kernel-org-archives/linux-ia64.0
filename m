From: wangyijing <wangyijing0307@gmail.com>
Date: Fri, 05 Sep 2014 11:33:08 +0000
Subject: Re: [PATCH v1 15/21] Powerpc/MSI: Use MSI chip framework to configure MSI/MSI-X irq
Message-Id: <43412AE0-85BB-4B4B-A4EA-2C6D3B8B85D7@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1409911806-10519-1-git-send-email-wangyijing@huawei.com> <1409911806-10519-16-git-send-email-wangyijing@huawei.com> <540994D4.6040500@cogentembedded.com>
In-Reply-To: <540994D4.6040500@cogentembedded.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Cc: Yijing Wang <wangyijing@huawei.com>, Bjorn Helgaas <bhelgaas@google.com>, Xinwei Hu <huxinwei@huawei.com>, Wuyun <wuyun.wu@huawei.com>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Russell King <linux@arm.linux.org.uk>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "arnab.basu@freescale.com" <arnab.basu@freescale.com>, "Bharat.Bhushan@freescale.com" <Bharat.Bhushan@freescale.com>, "x86@kernel.org" <x86@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>, Joerg Roedel <joro@8bytes.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "linux-mips@linux-mips.org" <linux-mips@linux-mips.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, Sebastian Ott <sebott@linux.vnet.ibm.com>, Tony Luck <tony.luck@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, Chris Metcalf <cmetcalf@tilera.com>, Ralf Baechle <ralf@linux-mips.org>

Cgo+INTaIDIwMTTE6jnUwjXI1aOsMTg6NDejrFNlcmdlaSBTaHR5bHlvdiA8c2VyZ2VpLnNodHls
eW92QGNvZ2VudGVtYmVkZGVkLmNvbT4g0LS1wKO6Cj4gCj4gSGVsbG8uCj4gCj4+IE9uIDkvNS8y
MDE0IDI6MTAgUE0sIFlpamluZyBXYW5nIHdyb3RlOgo+PiAKPj4gVXNlIE1TSSBjaGlwIGZyYW1l
d29yayBpbnN0ZWFkIG9mIGFyY2ggTVNJIGZ1bmN0aW9ucyB0byBjb25maWd1cmUKPj4gTVNJL01T
SS1YIGlycS4gU28gd2UgY2FuIG1hbmFnZSBNU0kvTVNJLVggaXJxIGluIGEgdW5pZmllZCBmcmFt
ZXdvcmsuCj4gCj4+IFNpZ25lZC1vZmYtYnk6IFlpamluZyBXYW5nIDx3YW5neWlqaW5nQGh1YXdl
aS5jb20+Cj4+IC0tLQo+PiAgYXJjaC9wb3dlcnBjL2tlcm5lbC9tc2kuYyB8ICAgMTQgKysrKysr
KysrKysrLS0KPj4gIDEgZmlsZXMgY2hhbmdlZCwgMTIgaW5zZXJ0aW9ucygrKSwgMiBkZWxldGlv
bnMoLSkKPiAKPj4gZGlmZiAtLWdpdCBhL2FyY2gvcG93ZXJwYy9rZXJuZWwvbXNpLmMgYi9hcmNo
L3Bvd2VycGMva2VybmVsL21zaS5jCj4+IGluZGV4IDcxYmQxNjEuLjAxNzgxYTQgMTAwNjQ0Cj4+
IC0tLSBhL2FyY2gvcG93ZXJwYy9rZXJuZWwvbXNpLmMKPj4gKysrIGIvYXJjaC9wb3dlcnBjL2tl
cm5lbC9tc2kuYwo+IFsuLi5dCj4+IEBAIC0yNyw3ICsyNywxNyBAQCBpbnQgYXJjaF9zZXR1cF9t
c2lfaXJxcyhzdHJ1Y3QgcGNpX2RldiAqZGV2LCBpbnQgbnZlYywgaW50IHR5cGUpCj4+ICAgICAg
cmV0dXJuIHBwY19tZC5zZXR1cF9tc2lfaXJxcyhkZXYsIG52ZWMsIHR5cGUpOwo+PiAgfQo+PiAK
Pj4gLXZvaWQgYXJjaF90ZWFyZG93bl9tc2lfaXJxcyhzdHJ1Y3QgcGNpX2RldiAqZGV2KQo+PiAr
c3RhdGljIHZvaWQgcHBjX3RlYXJkb3duX21zaV9pcnFzKHN0cnVjdCBwY2lfZGV2ICpkZXYpCj4g
Cj4gICBTaG91bGRuJ3QgdGhpcyBmdW5jdGlvbiB0YWtlIElSUSAjIGluc3RlYWQ/CgpUaGlzIGZ1
bmN0aW9uIG5lZWQgdG8gdGVhcmRvd24gYWxsIG1zaSBpcnFzIG9mIHRoZSBwY2kgZGV2LCB3ZSBz
aG91bGQgcGFzcyB0aGUgcGNpIGRldiBhcyBhcmd1bWVudCAuCgpUaGFua3MhCllpamluZy4KCj4g
Cj4+ICB7Cj4+ICAgICAgcHBjX21kLnRlYXJkb3duX21zaV9pcnFzKGRldik7Cj4+ICB9Cj4+ICsK
Pj4gK3N0YXRpYyBzdHJ1Y3QgbXNpX2NoaXAgcHBjX21zaV9jaGlwID0gewo+PiArICAgIC5zZXR1
cF9pcnFzID0gcHBjX3NldHVwX21zaV9pcnFzLAo+PiArICAgIC50ZWFyZG93bl9pcnFzID0gcHBj
X3RlYXJkb3duX21zaV9pcnFzLAo+PiArfTsKPj4gKwo+PiArc3RydWN0IG1zaV9jaGlwICphcmNo
X2ZpbmRfbXNpX2NoaXAoc3RydWN0IHBjaV9kZXYgKmRldikKPj4gK3sKPj4gKyAgICByZXR1cm4g
JnBwY19tc2lfY2hpcDsKPj4gK30KPiAKPiBXQlIsIFNlcmdlaQo+IAo+IC0tCj4gVG8gdW5zdWJz
Y3JpYmUgZnJvbSB0aGlzIGxpc3Q6IHNlbmQgdGhlIGxpbmUgInVuc3Vic2NyaWJlIGxpbnV4LXBj
aSIgaW4KPiB0aGUgYm9keSBvZiBhIG1lc3NhZ2UgdG8gbWFqb3Jkb21vQHZnZXIua2VybmVsLm9y
Zwo+IE1vcmUgbWFqb3Jkb21vIGluZm8gYXQgIGh0dHA6Ly92Z2VyLmtlcm5lbC5vcmcvbWFqb3Jk
b21vLWluZm8uaHRtbAotLQpUbyB1bnN1YnNjcmliZSBmcm9tIHRoaXMgbGlzdDogc2VuZCB0aGUg
bGluZSAidW5zdWJzY3JpYmUgbGludXgtaWE2NCIgaW4KdGhlIGJvZHkgb2YgYSBtZXNzYWdlIHRv
IG1ham9yZG9tb0B2Z2VyLmtlcm5lbC5vcmcKTW9yZSBtYWpvcmRvbW8gaW5mbyBhdCAgaHR0cDov
L3ZnZXIua2VybmVsLm9yZy9tYWpvcmRvbW8taW5mby5odG1s
