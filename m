From: Qian Cai <cai@lca.pw>
Date: Wed, 29 Jan 2020 11:09:56 +0000
Subject: Re: [PATCH V12] mm/debug: Add tests validating architecture page table helpers
Message-Id: <50B7EFFE-1FF0-4B16-84A1-D851052B18B4@lca.pw>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200128174709.GK655507@arrakis.emea.arm.com>
 <69091BA4-18C4-4425-A5E2-31FBE4654AF9@lca.pw>
 <20200129103640.GA668562@arrakis.emea.arm.com>
In-Reply-To: <20200129103640.GA668562@arrakis.emea.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1254"
Content-Transfer-Encoding: base64
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Mark Rutland <Mark.Rutland@arm.com>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, James Hogan <jhogan@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, linux-s390@vger.kernel.org, Jason Gunthorpe <jgg@ziepe.ca>, Michael Ellerman <mpe@ellerman.id.au>, the arch/x86 maintainers <x86@kernel.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, Matthew Wilcox <willy@infradead.org>, Steven Price <Steven.Price@arm.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Vlastimil Babka <vbabka@suse.cz>, linux-snps-arc@lists.infradead.org, Kees Cook <keescook@chromium.org>, Anshuman Khandual <Anshuman.Khandual@arm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Mark Brown <broonie@kernel.org>, "Kirill A . Shutemov" <kirill@shutemov.name>, Dan Williams <dan.j.williams@intel.com>, linux-arm-kernel@lists.infradead.org, Christophe Leroy <christophe.leroy@c-s.fr>, Sri Krishna chowdary <schowdary@nvidia.com>, Masahiro Yamada <yamada.masahiro@socionext.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Dave Hansen <dave.hansen@intel.com>, linux-mips@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, linux-kernel@vger.kernel.org, Paul Burton <paul.burton@mips.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Vineet Gupta <vgupta@synopsys.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>

Cgo+IE9uIEphbiAyOSwgMjAyMCwgYXQgNTozNiBBTSwgQ2F0YWxpbiBNYXJpbmFzIDxjYXRhbGlu
Lm1hcmluYXNAYXJtLmNvbT4gd3JvdGU6Cj4gCj4gT24gVHVlLCBKYW4gMjgsIDIwMjAgYXQgMDI6
MDc6MTBQTSAtMDUwMCwgUWlhbiBDYWkgd3JvdGU6Cj4+IE9uIEphbiAyOCwgMjAyMCwgYXQgMTI6
NDcgUE0sIENhdGFsaW4gTWFyaW5hcyA8Y2F0YWxpbi5tYXJpbmFzQGFybS5jb20+IHdyb3RlOgo+
Pj4gVGhlIHByaW1hcnkgZ29hbCBoZXJlIGlzIG5vdCBmaW5kaW5nIHJlZ3Jlc3Npb25zIGJ1dCBo
YXZpbmcgY2xlYXJseQo+Pj4gZGVmaW5lZCBzZW1hbnRpY3Mgb2YgdGhlIHBhZ2UgdGFibGUgYWNj
ZXNzb3JzIGFjcm9zcyBhcmNoaXRlY3R1cmVzLiB4ODYKPj4+IGFuZCBhcm02NCBhcmUgYSBnb29k
IHN0YXJ0aW5nIHBvaW50IGFuZCBvdGhlciBhcmNoaXRlY3R1cmVzIHdpbGwgYmUKPj4+IGVuYWJs
ZWQgYXMgdGhleSBhcmUgYWxpZ25lZCB0byB0aGUgc2FtZSBzZW1hbnRpY3MuCj4+IAo+PiBUaGlz
IHN0aWxsIGRvZXMgbm90IGFuc3dlciB0aGUgZnVuZGFtZW50YWwgcXVlc3Rpb24uIElmIHRoaXMg
dGVzdCBpcwo+PiBzaW1wbHkgaW5lZmZpY2llbnQgdG8gZmluZCBidWdzLAo+IAo+IFdobyBzYWlk
IHRoaXMgaXMgaW5lZmZpY2llbnQgKG90aGVyIHRoYW4geW91KT8KCkluZWZmaWNpZW50IG9mIGZp
bmRpbmcgYnVncy4gSXQgc2FpZCBvbmx5IGZvdW5kIGEgYnVnIG9yIHR3byBpbiBpdHMgbGlmZXRp
bWU/Cgo+IAo+PiB3aG8gd2FudHMgdG8gc3BlbmQgdGltZSB0byB1c2UgaXQgcmVndWxhcmx5PyAK
PiAKPiBBcmNoIG1haW50YWluZXJzLCBtbSBtYWludGFpbmVycyBpbnRyb2R1Y2luZyBuZXcgbWFj
cm9zIG9yIGFzc3VtaW5nCj4gY2VydGFpbiBuZXcgc2VtYW50aWNzIG9mIHRoZSBleGlzdGluZyBt
YWNyb3MuCj4gCj4+IElmIHRoaXMgaXMganVzdCBvbmUgb2ZmIHRlc3QgdGhhdCBtYXkgZ2V0IHJ1
bm5pbmcgb25jZSBpbiBhIGZldyB5ZWFycwo+PiAod2hlbiBpbnRyb2R1Y2luZyBhIG5ldyBhcmNo
KSwgaG93IGRvZXMgaXQganVzdGlmeSB0aGUgb25nb2luZyBjb3N0IHRvCj4+IG1haW50YWluIGl0
Pwo+IAo+IFlvdSBhcmUgcmVhbGx5IG1pc3NpbmcgdGhlIHBvaW50LiBJdCdzIG5vdCBvbmx5IGZv
ciBhIG5ldyBhcmNoIGJ1dAo+IGNoYW5nZXMgdG8gZXhpc3RpbmcgYXJjaCBjb2RlLiBBbmQgaWYg
dGhlIGFyY2ggY29kZSBjaHVybiBpbiB0aGlzIGFyZWEKPiBpcyByZWxhdGl2ZWx5IHNtYWxsLCBJ
J2QgZXhwZWN0IGEgc2ltaWxhcmx5IHNtYWxsIGNvc3Qgb2YgbWFpbnRhaW5pbmcKPiB0aGlzIHRl
c3QuCj4gCj4gSWYgeW91IG9ubHkgdHVybiBERUJVR19WTSBvbiBvbmNlIGV2ZXJ5IGZldyB5ZWFy
cywgZG9uJ3QgZ2VuZXJhbGlzZSB0aGlzCj4gdG8gdGhlIHJlc3Qgb2YgdGhlIGtlcm5lbCBkZXZl
bG9wZXJzIChhcyBvdGhlcnMgcG9pbnRlZCBvdXQsIHRoaXMgdGVzdAo+IGlzIGRlZmF1bHQgeSBp
ZiBERUJVR19WTSkuCgpRdWl0ZSB0aGUgb3Bwb3NpdGUsIEkgYW0gcnVubmluZyBERUJVR19WTSBh
bG1vc3QgZGFpbHkgZm9yIHJlZ3Jlc3Npb24Kd29ya2xvYWQgd2hpbGUgSSBmZWx0IHN0cm9uZ2x5
IHRoaXMgdGhpbmcgZG9lcyBub3QgYWRkIGFueSB2YWx1ZSBtaXhpbmcgdGhlcmUuCgpTbywgSSB3
b3VsZCBzdWdnZXN0IHRvIGRlY291cGxlIHRoaXMgYXdheSBmcm9tIERFQlVHX1ZNLCBhbmQgY2xl
YXJseQpkb2N1bWVudCB0aGF0IHRoaXMgdGVzdCBpcyBub3Qgc29tZXRoaW5nIGludGVuZGVkIGZv
ciBhdXRvbWF0ZWQgcmVncmVzc2lvbgp3b3JrbG9hZHMsIHNvIHRob3NlIHBlb3BsZSBkb27igJl0
IG5lZWQgdG8gd2FzdGUgdGltZSBydW5uaW5nIHRoaXMuCgo+IAo+IEFueXdheSwgSSB0aGluayB0
aGF0J3MgYSBwb2ludGxlc3MgZGlzY3Vzc2lvbiwgc28gbm90IGdvaW5nIHRvIHJlcGx5Cj4gZnVy
dGhlciAodW5sZXNzIHlvdSBoYXZlIHRlY2huaWNhbCBjb250ZW50IHRvIGFkZCkuCj4gCj4gLS0g
Cj4gQ2F0YWxpbgo=
