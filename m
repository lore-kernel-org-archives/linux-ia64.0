From: Justin He <Justin.He@arm.com>
Date: Thu, 09 Jul 2020 09:36:42 +0000
Subject: RE: [PATCH v3 4/6] mm: don't export memory_add_physaddr_to_nid in arch specific directory
Message-Id: <AM6PR08MB406932241B7FB3753B77B113F7640@AM6PR08MB4069.eurprd08.prod.outlook.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200709020629.91671-1-justin.he@arm.com>
 <20200709020629.91671-5-justin.he@arm.com>
 <20200709021104.GZ25523@casper.infradead.org>
 <20200709091815.GF781326@linux.ibm.com>
 <49a53674-f246-fdd6-009b-447a88cdb68e@redhat.com>
In-Reply-To: <49a53674-f246-fdd6-009b-447a88cdb68e@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Hildenbrand <david@redhat.com>, Mike Rapoport <rppt@linux.ibm.com>, Matthew Wilcox <willy@infradead.org>
Cc: Catalin Marinas <Catalin.Marinas@arm.com>, Will Deacon <will@kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "x86@kernel.org" <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Baoquan He <bhe@redhat.com>, Chuhong Yuan <hslester96@gmail.com>, Masahiro Yamada <masahiroy@kernel.org>, Michal Hocko <mhocko@suse.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.>, org, , "linux-mm@kvack.org" <linux-mm@kvack.org>, Jonathan Cameron <Jonathan.Cameron@huawei.com>, Kaly Xin <Kaly.Xin@arm.com>

SGkgRGF2aWQNCg0KPiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBEYXZpZCBI
aWxkZW5icmFuZCA8ZGF2aWRAcmVkaGF0LmNvbT4NCj4gU2VudDogVGh1cnNkYXksIEp1bHkgOSwg
MjAyMCA1OjE5IFBNDQo+IFRvOiBNaWtlIFJhcG9wb3J0IDxycHB0QGxpbnV4LmlibS5jb20+OyBN
YXR0aGV3IFdpbGNveA0KPiA8d2lsbHlAaW5mcmFkZWFkLm9yZz4NCj4gQ2M6IEp1c3RpbiBIZSA8
SnVzdGluLkhlQGFybS5jb20+OyBDYXRhbGluIE1hcmluYXMNCj4gPENhdGFsaW4uTWFyaW5hc0Bh
cm0uY29tPjsgV2lsbCBEZWFjb24gPHdpbGxAa2VybmVsLm9yZz47IFRvbnkgTHVjaw0KPiA8dG9u
eS5sdWNrQGludGVsLmNvbT47IEZlbmdodWEgWXUgPGZlbmdodWEueXVAaW50ZWwuY29tPjsgWW9z
aGlub3JpIFNhdG8NCj4gPHlzYXRvQHVzZXJzLnNvdXJjZWZvcmdlLmpwPjsgUmljaCBGZWxrZXIg
PGRhbGlhc0BsaWJjLm9yZz47IERhdmUgSGFuc2VuDQo+IDxkYXZlLmhhbnNlbkBsaW51eC5pbnRl
bC5jb20+OyBBbmR5IEx1dG9taXJza2kgPGx1dG9Aa2VybmVsLm9yZz47IFBldGVyDQo+IFppamxz
dHJhIDxwZXRlcnpAaW5mcmFkZWFkLm9yZz47IFRob21hcyBHbGVpeG5lciA8dGdseEBsaW51dHJv
bml4LmRlPjsNCj4gSW5nbyBNb2xuYXIgPG1pbmdvQHJlZGhhdC5jb20+OyBCb3Jpc2xhdiBQZXRr
b3YgPGJwQGFsaWVuOC5kZT47DQo+IHg4NkBrZXJuZWwub3JnOyBILiBQZXRlciBBbnZpbiA8aHBh
QHp5dG9yLmNvbT47IERhbiBXaWxsaWFtcw0KPiA8ZGFuLmoud2lsbGlhbXNAaW50ZWwuY29tPjsg
VmlzaGFsIFZlcm1hIDx2aXNoYWwubC52ZXJtYUBpbnRlbC5jb20+OyBEYXZlDQo+IEppYW5nIDxk
YXZlLmppYW5nQGludGVsLmNvbT47IEFuZHJldyBNb3J0b24gPGFrcG1AbGludXgtZm91bmRhdGlv
bi5vcmc+Ow0KPiBCYW9xdWFuIEhlIDxiaGVAcmVkaGF0LmNvbT47IENodWhvbmcgWXVhbiA8aHNs
ZXN0ZXI5NkBnbWFpbC5jb20+OyBMb2dhbg0KPiBHdW50aG9ycGUgPGxvZ2FuZ0BkZWx0YXRlZS5j
b20+OyBNYXNhaGlybyBZYW1hZGEgPG1hc2FoaXJveUBrZXJuZWwub3JnPjsNCj4gTWljaGFsIEhv
Y2tvIDxtaG9ja29Ac3VzZS5jb20+OyBsaW51eC1hcm0ta2VybmVsQGxpc3RzLmluZnJhZGVhZC5v
cmc7DQo+IGxpbnV4LWtlcm5lbEB2Z2VyLmtlcm5lbC5vcmc7IGxpbnV4LWlhNjRAdmdlci5rZXJu
ZWwub3JnOyBsaW51eC0NCj4gc2hAdmdlci5rZXJuZWwub3JnOyBsaW51eC1udmRpbW1AbGlzdHMu
MDEub3JnOyBsaW51eC1tbUBrdmFjay5vcmc7DQo+IEpvbmF0aGFuIENhbWVyb24gPEpvbmF0aGFu
LkNhbWVyb25AaHVhd2VpLmNvbT47IEthbHkgWGluIDxLYWx5LlhpbkBhcm0uY29tPg0KPiBTdWJq
ZWN0OiBSZTogW1BBVENIIHYzIDQvNl0gbW06IGRvbid0IGV4cG9ydCBtZW1vcnlfYWRkX3BoeXNh
ZGRyX3RvX25pZCBpbg0KPiBhcmNoIHNwZWNpZmljIGRpcmVjdG9yeQ0KPiANCj4gT24gMDkuMDcu
MjAgMTE6MTgsIE1pa2UgUmFwb3BvcnQgd3JvdGU6DQo+ID4gT24gVGh1LCBKdWwgMDksIDIwMjAg
YXQgMDM6MTE6MDRBTSArMDEwMCwgTWF0dGhldyBXaWxjb3ggd3JvdGU6DQo+ID4+IE9uIFRodSwg
SnVsIDA5LCAyMDIwIGF0IDEwOjA2OjI3QU0gKzA4MDAsIEppYSBIZSB3cm90ZToNCj4gPj4+IEFm
dGVyIGEgZ2VuZXJhbCB2ZXJzaW9uIG9mIF9fd2VhayBtZW1vcnlfYWRkX3BoeXNhZGRyX3RvX25p
ZA0KPiBpbXBsZW1lbnRlZA0KPiA+Pj4gYW5kIGV4cG9ydGVkICwgaXQgaXMgbm8gdXNlIGV4cG9y
dGluZyB0d2ljZSBpbiBhcmNoIGRpcmVjdG9yeSBldmVuIGlmDQo+ID4+PiBlLGcsIGlhNjQveDg2
IGhhdmUgdGhlaXIgc3BlY2lmaWMgdmVyc2lvbi4NCj4gPj4+DQo+ID4+PiBUaGlzIGlzIHRvIHN1
cHByZXNzIHRoZSBtb2Rwb3N0IHdhcm5pbmc6DQo+ID4+PiBXQVJOSU5HOiBtb2Rwb3N0OiB2bWxp
bnV4OiAnbWVtb3J5X2FkZF9waHlzYWRkcl90b19uaWQnIGV4cG9ydGVkIHR3aWNlLg0KPiA+Pj4g
UHJldmlvdXMgZXhwb3J0IHdhcyBpbiB2bWxpbnV4DQo+ID4+DQo+ID4+IEl0J3MgYmFkIGZvcm0g
dG8gaW50cm9kdWNlIGEgd2FybmluZyBhbmQgdGhlbiBzZW5kIGEgZm9sbG93LXVwIHBhdGNoIHRv
DQo+ID4+IGZpeCB0aGUgd2FybmluZy4gIEp1c3QgZm9sZCB0aGlzIHBhdGNoIGludG8gcGF0Y2gg
MS82Lg0KPiA+DQo+ID4gTW9yZW92ZXIsIEkgdGhpbmsgdGhhdCBwYXRjaGVzIDEtNCBjYW4gYmUg
bWVyZ2VkIGludG8gb25lLg0KPiA+DQo+IA0KPiArMQ0KDQpPa2F5LCB3aWxsIHVwZGF0ZSwgdGhh
bmtzDQoNCi0tDQpDaGVlcnMsDQpKdXN0aW4gKEppYSBIZSkNCg0KDQo
