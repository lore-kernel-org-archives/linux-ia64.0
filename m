From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Date: Thu, 18 Mar 2021 00:40:18 +0000
Subject: Re: [PATCH v2] mm: Move mem_init_print_info() into mm_init()
Message-Id: <ea5a9027-b0a6-e06d-b3ac-00b8ac43883e@synopsys.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4d488195-7281-9238-b30d-9f89a6100fb9@csgroup.eu>
 <20210317015210.33641-1-wangkefeng.wang@huawei.com>
In-Reply-To: <20210317015210.33641-1-wangkefeng.wang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kefeng Wang <wangkefeng.wang@huawei.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Richard Henderson <rth@twiddle.net>, Guo Ren <guoren@kernel.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, Huacai Chen <chenhuacai@kernel.org>, Jonas Bonn <jonas@southpole.se>, Palmer Dabbelt <palmer@dabbelt.com>, Heiko Carstens <hca@linux.ibm.com>, "David S. Miller" <davem@davemloft.net>, Dave Hansen <dave.hansen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, "linux-alpha@vger.kernel.org" <linux-alpha@vger.kernel.org>, "linux-snps-arc@lists.infradead.org" <linux-snps-arc@lists.infradead.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-csky@vger.kernel.org" <linux-csky@vger.kernel.org>, "linux-hexagon@vger.kernel.org" <linux-hexagon@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-m68k@lists.linux-m68k.org" <linux-m68k@lists.linux-m68k.org>, "linux-mips@vger.kernel.org" <linux-mips@vger.kernel.org>, "openrisc@lists.librecores.org" <openrisc@lists.librecores.org>, "linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "linux-riscv@lists.infradea" <linux-riscv@lists.infradea>

T24gMy8xNi8yMSA2OjUyIFBNLCBLZWZlbmcgV2FuZyB3cm90ZToNCj4gbWVtX2luaXRfcHJpbnRf
aW5mbygpIGlzIGNhbGxlZCBpbiBtZW1faW5pdCgpIG9uIGVhY2ggYXJjaGl0ZWN0dXJlLA0KPiBh
bmQgcGFzcyBOVUxMIGFyZ3VtZW50LCBzbyB1c2luZyB2b2lkIGFyZ3VtZW50IGFuZCBtb3ZlIGl0
IGludG8gbW1faW5pdCgpLg0KPiANCj4gQWNrZWQtYnk6IERhdmUgSGFuc2VuIDxkYXZlLmhhbnNl
bkBsaW51eC5pbnRlbC5jb20+DQo+IFNpZ25lZC1vZmYtYnk6IEtlZmVuZyBXYW5nIDx3YW5na2Vm
ZW5nLndhbmdAaHVhd2VpLmNvbT4NCg0KQWNrZWQtYnk6IFZpbmVldCBHdXB0YSA8dmd1cHRhQHN5
bm9wc3lzLmNvbT4NCg0KVGh4LA0KLVZpbmVldA0K
