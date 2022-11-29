From: Nadav Amit <namit@vmware.com>
Date: Tue, 29 Nov 2022 17:56:14 +0000
Subject: Re: [PATCH 3/3] compiler: inline does not imply notrace
Message-Id: <58C520A0-D263-4F08-B1CB-D32C043865F2@vmware.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20221122195329.252654-1-namit@vmware.com>
 <20221122195329.252654-4-namit@vmware.com>
 <de999ab8-78ff-44f7-aacc-68561897c6e2@app.fastmail.com>
 <B764D38F-470D-4022-A818-73814F442473@vmware.com>
 <4BDE3655-CCC3-412B-9DDB-226485113706@vmware.com>
 <20221128231532.40210855@gandalf.local.home>
 <2CFF9131-48E9-44D3-93CA-976C47106092@vmware.com>
 <20221129100647.4957579e@gandalf.local.home>
In-Reply-To: <20221129100647.4957579e@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, kernel list <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-um@lists.infradead.org" <linux-um@lists.infradead.org>, Linux-Arch <linux-arch@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, X86 ML <x86@kernel.org>, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Johannes Berg <johannes@sipsolutions.net>, Andrew Morton <akpm@linux-foundation.org>

T24gTm92IDI5LCAyMDIyLCBhdCA3OjA2IEFNLCBTdGV2ZW4gUm9zdGVkdCA8cm9zdGVkdEBnb29k
bWlzLm9yZz4gd3JvdGU6DQoNCj4gT24gVHVlLCAyOSBOb3YgMjAyMiAwNDoyNTozOCArMDAwMA0K
PiBOYWRhdiBBbWl0IDxuYW1pdEB2bXdhcmUuY29tPiB3cm90ZToNCj4gDQo+IA0KPj4gSSB3aWxs
IG5lZWQgdG8gZnVydGhlciBkZWJ1ZyBpdCwgYnV0IHRoaXMgaXNzdWUgZG9lcyBub3Qgb2NjdXIg
ZXZlcnkgdGltZS4NCj4+IA0KPj4gVGhlIGtlcm5lbCBkaWRu4oCZdCBjcmFzaCBleGFjdGx5IC0g
aXTigJlzIG1vcmUgb2YgYSBkZWFkbG9jay4gSSBoYXZlIGxvY2tkZXANCj4+IGVuYWJsZWQsIHNv
IGl0IGlzIG5vdCBhIGRlYWRsb2NrIHRoYXQgbG9ja2RlcCBrbm93cy4gQ291bGQgaXQgYmUgdGhh
dA0KPj4gc29tZWhvdyB0aGluZ3MganVzdCBzbG93ZWQgZG93biBkdWUgdG8gSVBJcyBhbmQgbW9z
dGx5LWRpc2FibGVkIElSUXM/IEkgaGF2ZQ0KPj4gbm8gaWRlYS4gSSB3b3VsZCBuZWVkIHRvIHJl
Y3JlYXRlIHRoZSBzY2VuYXJpby4gDQo+IA0KPiBZb3UgaGF2ZSBsb2NrZGVwIGVuYWJsZWQgYW5k
IHlvdSBhcmUgcnVubmluZyBmdW5jdGlvbiB0cmFjaW5nIHdpdGggc3RhY2sNCj4gdHJhY2Ugb24/
IFNvIHlvdSBhcmUgZG9pbmcgYSBzdGFjayB0cmFjZSBvbiAqZXZlcnkqIGZ1bmN0aW9uIHRoYXQg
aXMgdHJhY2VkPw0KPiANCj4gSSBkb24ndCB0aGluayB5b3UgaGl0IGEgZGVhZGxvY2ssIEkgdGhp
bmsgeW91IGhpdCBhIGxpdmUgbG9jay4gWW91IGNvdWxkDQo+IHBvc3NpYmx5IHNsb3cgdGhlIHN5
c3RlbSBkb3duIHNvIG11Y2ggdGhhdCB3aGVuIGFuIGludGVycnVwdCBmaW5pc2hlcyBpdCdzDQo+
IHRpbWUgZm9yIGl0IHRvIGJlIHRyaWdnZXJlZCBhZ2FpbiwgYW5kIHlvdSBuZXZlciBtYWtlIGZv
cndhcmQgcHJvZ3Jlc3MuDQoNCkl0IG1pZ2h0IGJlIHRoZSBpc3N1ZS4gUGVyaGFwcyBJIGhhdmUg
YSBidWcsIGJlY2F1c2UgbXkgY29kZSB3YXMgc3VwcG9zZWQgdG8NCmVpdGhlciBlbmFibGUgc3Rh
Y2stdHJhY2luZyB3aXRoIHNlbGVjdGVkIGZ1bmN0aW9ucyBvciBjcmVhdGUgYSB0cmFjZSBhbGwN
CmZ1bmN0aW9uIGJ1dCAqd2l0aG91dCogc3RhY2stdHJhY2luZy4NCg0KVGhhbmtzIGZvciB0aGUg
cG9pbnRlciBhbmQgc29ycnkgZm9yIHRoZSBub2lzZS4NCg0KUmVnYXJkcywNCk5hZGF2
