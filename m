From: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Date: Thu, 06 Sep 2018 13:04:47 +0000
Subject: Re: [RFC PATCH 00/29] mm: remove bootmem allocator
Message-Id: <46ae5e64-7b1a-afab-bfef-d00183a7ef76@microsoft.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1536163184-26356-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20180906091538.GN14951@dhcp22.suse.cz>
In-Reply-To: <20180906091538.GN14951@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michal Hocko <mhocko@kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ingo Molnar <mingo@redhat.com>, Michael Ellerman <mpe@ellerman.id.au>, Paul Burton <paul.burton@mips.com>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-mips@linux-mips.org" <linux-mips@linux-mips.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

DQoNCk9uIDkvNi8xOCA1OjE1IEFNLCBNaWNoYWwgSG9ja28gd3JvdGU6DQo+IE9uIFdlZCAwNS0w
OS0xOCAxODo1OToxNSwgTWlrZSBSYXBvcG9ydCB3cm90ZToNCj4gWy4uLl0NCj4+ICAzMjUgZmls
ZXMgY2hhbmdlZCwgODQ2IGluc2VydGlvbnMoKyksIDI0NzggZGVsZXRpb25zKC0pDQo+PiAgZGVs
ZXRlIG1vZGUgMTAwNjQ0IGluY2x1ZGUvbGludXgvYm9vdG1lbS5oDQo+PiAgZGVsZXRlIG1vZGUg
MTAwNjQ0IG1tL2Jvb3RtZW0uYw0KPj4gIGRlbGV0ZSBtb2RlIDEwMDY0NCBtbS9ub2Jvb3RtZW0u
Yw0KPiANCj4gVGhpcyBpcyByZWFsbHkgaW1wcmVzc2l2ZSEgVGhhbmtzIGEgbG90IGZvciB3b3Jr
aW5nIG9uIHRoaXMuIEkgd2lzaCB3ZQ0KPiBjb3VsZCBzaW1wbGlmeSB0aGUgbWVtYmxvY2sgQVBJ
IGFzIHdlbGwuIFRoZXJlIGFyZSBqdXN0IHRvbyBtYW55IHB1YmxpYw0KPiBmdW5jdGlvbnMgd2l0
aCBzdWJ0bHkgZGlmZmVyZW50IHNlbWFudGljIGFuZCBiYXJlbHkgYW55IHVzZWZ1bA0KPiBkb2N1
bWVudGF0aW9uLg0KPiANCj4gQnV0IGV2ZW4gdGhpcyBpcyBhIGdyZWF0IHN0ZXAgZm9yd2FyZCEN
Cg0KVGhpcyBpcyBhIGdyZWF0IHNpbXBsaWZpY2F0aW9uIG9mIGJvb3QgcHJvY2Vzcy4gVGhhbmsg
eW91IE1pa2UhDQoNCkkgYWdyZWUsIHdpdGggTWljaGFsIGluIHRoZSBmdXR1cmUsIG9uY2Ugbm9i
b290bWVtIGtlcm5lbCBzdGFiYWxpemVzDQphZnRlciB0aGlzIGVmZm9ydCwgd2Ugc2hvdWxkIHN0
YXJ0IHNpbXBsaWZ5aW5nIG1lbWJsb2NrIGFsbG9jYXRvciBBUEk6DQppdCB3b24ndCBiZSBhcyBi
aWcgZWZmb3J0IGFzIHRoaXMgb25lLCBhcyBJIHRoaW5rLCB0aGF0IGNhbiBiZSBkb25lIGluDQpp
bmNyZW1lbnRhbCBwaGFzZXMsIGJ1dCBpdCB3aWxsIGhlbHAgdG8gbWFrZSBlYXJseSBib290IG11
Y2ggbW9yZSBzdGFibGUNCmFuZCB1bmlmb3JtIGFjcm9zcyBhcmNoZXMuDQoNClRoYW5rIHlvdSwN
ClBhdmVs
