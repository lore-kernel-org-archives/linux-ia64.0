From: Christophe Leroy <christophe.leroy@csgroup.eu>
Date: Tue, 14 Feb 2023 07:19:27 +0000
Subject: Re: [PATCH v2 12/24] powerpc/cpu: Mark start_secondary_resume() __noreturn
Message-Id: <3a1be09c-b9fd-a473-0819-81a4ebdf34cc@csgroup.eu>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1676358308.git.jpoimboe@kernel.org>
 <b6b2141f832d8cd8ade65f190d04b011cda5f9bb.1676358308.git.jpoimboe@kernel.org>
In-Reply-To: 
 <b6b2141f832d8cd8ade65f190d04b011cda5f9bb.1676358308.git.jpoimboe@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Josh Poimboeuf <jpoimboe@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: "jgross@suse.com" <jgross@suse.com>, "richard.henderson@linaro.org" <richard.henderson@linaro.org>, "ink@jurassic.park.msu.ru" <ink@jurassic.park.msu.ru>, "mattst88@gmail.com" <mattst88@gmail.com>, "linux-alpha@vger.kernel.org" <linux-alpha@vger.kernel.org>, "linux@armlinux.org.uk" <linux@armlinux.org.uk>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "will@kernel.org" <will@kernel.org>, "guoren@kernel.org" <guoren@kernel.org>, "linux-csky@vger.kernel.org" <linux-csky@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "chenhuacai@kernel.org" <chenhuacai@kernel.org>, "kernel@xen0n.name" <kernel@xen0n.name>, "loongarch@lists.linux.dev" <loongarch@lists.linux.dev>, "f.fainelli@gmail.com" <f.fainelli@gmail.com>, "bcm-kernel-feedback-list@broadcom.com" <bcm-kernel-feedback-list@broadcom.com>, "tsbogend@alpha.franken.de" <tsbogend@alpha.franken.de>, "linux-mips@vger.kernel.org" <linux-mips@vger.kernel.org>, "jiaxun.yang@flygoat.com" <jiaxun.yang@flygoat.com>, "mpe@ellerman.id.au" <mpe@ellerman.id.au>, "npiggin@gmail.com" <npiggin@gmail.com>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "ysato@users.sourceforge.jp" <ysato@users.sourceforge.jp>, "dalias@libc.org" <dalias@libc.org>, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, "davem@davemloft.net" <davem@davemloft.net>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "mingo@redhat.com" <mingo@redhat.com>, "bp@alien8.de" <bp@alien8.de>, "dave.hansen@linux.intel.com" <dave.hansen@linux.intel.com>, "x86@kernel.org" <x86@kernel.org>, "hpa@zytor.com" <hpa@zytor.com>, "chris@zankel.net" <chris@zankel.net>, "jcmvbkbc@gmail.com" <jcmvbkbc@gmail.com>, "linux-xtensa@linux-xtensa.org" <linux-xtensa@linux-xtensa.org>, "peterz@infradead.org" <peterz@infradead.org>, "juri.lelli@redhat.com" <juri.lelli@redhat.com>, "vincent.guittot@linaro.org" <vincent.guittot@linaro.org>, "dietmar.eggemann@arm.com" <dietmar.eggemann@arm.com>, "rostedt@goodmis.org" <rostedt@goodmis.org>, "bsegall@google.com" <bsegall@google.com>, "mgorman@suse.de" <mgorman@suse.de>, "bristot@redhat.com" <bristot@redhat.com>, "vschneid@redhat.com" <vschneid@redhat.com>, "paulmck@kernel.org" <paulmck@kernel.org>

DQoNCkxlIDE0LzAyLzIwMjMgw6AgMDg6MDUsIEpvc2ggUG9pbWJvZXVmIGEgw6ljcml0wqA6DQo+
IHN0YXJ0X3NlY29uZGFyeV9yZXN1bWUoKSBkb2Vzbid0IHJldHVybi4gIEFubm90YXRlIGl0IGFz
IHN1Y2guICBCeQ0KPiBleHRlbnNpb24gdGhpcyBhbHNvIG1ha2VzIGFyY2hfY3B1X2lkbGVfZGVh
ZCgpIG5vcmV0dXJuLg0KPiANCj4gQWNrZWQtYnk6IE1pY2hhZWwgRWxsZXJtYW4gPG1wZUBlbGxl
cm1hbi5pZC5hdT4gKHBvd2VycGMpDQo+IFNpZ25lZC1vZmYtYnk6IEpvc2ggUG9pbWJvZXVmIDxq
cG9pbWJvZUBrZXJuZWwub3JnPg0KDQpSZXZpZXdlZC1ieTogQ2hyaXN0b3BoZSBMZXJveSA8Y2hy
aXN0b3BoZS5sZXJveUBjc2dyb3VwLmV1Pg0KDQo+IC0tLQ0KPiAgIGFyY2gvcG93ZXJwYy9pbmNs
dWRlL2FzbS9zbXAuaCB8IDIgKy0NCj4gICAxIGZpbGUgY2hhbmdlZCwgMSBpbnNlcnRpb24oKyks
IDEgZGVsZXRpb24oLSkNCj4gDQo+IGRpZmYgLS1naXQgYS9hcmNoL3Bvd2VycGMvaW5jbHVkZS9h
c20vc21wLmggYi9hcmNoL3Bvd2VycGMvaW5jbHVkZS9hc20vc21wLmgNCj4gaW5kZXggZjYzNTA1
ZDc0OTMyLi5jZmQ0MmNhODc2NWMgMTAwNjQ0DQo+IC0tLSBhL2FyY2gvcG93ZXJwYy9pbmNsdWRl
L2FzbS9zbXAuaA0KPiArKysgYi9hcmNoL3Bvd2VycGMvaW5jbHVkZS9hc20vc21wLmgNCj4gQEAg
LTY2LDcgKzY2LDcgQEAgdm9pZCBzdGFydF9zZWNvbmRhcnkodm9pZCAqdW51c2VkKTsNCj4gICBl
eHRlcm4gaW50IHNtcF9zZW5kX25taV9pcGkoaW50IGNwdSwgdm9pZCAoKmZuKShzdHJ1Y3QgcHRf
cmVncyAqKSwgdTY0IGRlbGF5X3VzKTsNCj4gICBleHRlcm4gaW50IHNtcF9zZW5kX3NhZmVfbm1p
X2lwaShpbnQgY3B1LCB2b2lkICgqZm4pKHN0cnVjdCBwdF9yZWdzICopLCB1NjQgZGVsYXlfdXMp
Ow0KPiAgIGV4dGVybiB2b2lkIHNtcF9zZW5kX2RlYnVnZ2VyX2JyZWFrKHZvaWQpOw0KPiAtZXh0
ZXJuIHZvaWQgc3RhcnRfc2Vjb25kYXJ5X3Jlc3VtZSh2b2lkKTsNCj4gK2V4dGVybiB2b2lkIF9f
bm9yZXR1cm4gc3RhcnRfc2Vjb25kYXJ5X3Jlc3VtZSh2b2lkKTsNCg0KV291bGQgaGF2ZSBiZWVu
IGEgZ29vZCBvcHBvcnR1bml0eSB0byBkcm9wIHRoZSBwb2ludGxlc3MgJ2V4dGVybicga2V5d29y
ZC4NCg0KQ2hlY2twYXRjaCByZXBvcnRzOg0KDQpDSEVDSzogZXh0ZXJuIHByb3RvdHlwZXMgc2hv
dWxkIGJlIGF2b2lkZWQgaW4gLmggZmlsZXMNCiMxOTogRklMRTogYXJjaC9wb3dlcnBjL2luY2x1
ZGUvYXNtL3NtcC5oOjY5Og0KK2V4dGVybiB2b2lkIF9fbm9yZXR1cm4gc3RhcnRfc2Vjb25kYXJ5
X3Jlc3VtZSh2b2lkKTsNCg0KDQo+ICAgZXh0ZXJuIHZvaWQgc21wX2dlbmVyaWNfZ2l2ZV90aW1l
YmFzZSh2b2lkKTsNCj4gICBleHRlcm4gdm9pZCBzbXBfZ2VuZXJpY190YWtlX3RpbWViYXNlKHZv
aWQpOw0KPiAgIA0K
