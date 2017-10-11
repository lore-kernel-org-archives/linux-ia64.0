From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 11 Oct 2017 21:22:08 +0000
Subject: RE: [PATCH v4 2/2] pid: Remove pidhash
Message-Id: <3908561D78D1C84285E8C5FCA982C28F770037C6@ORSMSX114.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <201710111737.ZHqmaPa5%fengguang.wu@intel.com>
 <1507731304.21121.185.camel@surriel.com>
In-Reply-To: <1507731304.21121.185.camel@surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Rik van Riel <riel@surriel.com>, lkp <lkp@intel.com>, Gargi Sharma <gs051095@gmail.com>
Cc: "kbuild-all@01.org" <kbuild-all@01.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "julia.lawall@lip6.fr" <julia.lawall@lip6.fr>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mingo@kernel.org" <mingo@kernel.org>, "pasha.tatashin@oracle.com" <pasha.tatashin@oracle.com>, "ktkhai@virtuozzo.com" <ktkhai@virtuozzo.com>, "oleg@redhat.com" <oleg@redhat.com>, "ebiederm@xmission.com" <ebiederm@xmission.com>, "hch@infradead.org" <hch@infradead.org>, linux-ia64 <linux-ia64@vger.kernel.org>

PsKgwqDCoMKgwqDCoMKgwqBERUZJTkUoSUE2NF9VUElEX1NISUZULCA1KTsNCj4NCj4gR3JlcHBp
bmcgZm9yIElBNjRfVVBJRF9TSElGVCBsZWFkcyB1cyB0byBzb21lIGFzc2VtYmx5DQo+IGNvZGUg
aW1wbGVtZW50aW5nIGZzeXNfZ2V0cGlkICh3aHkgaXMgdGhhdCBpbiBhc3NlbWJseT8hKToNCg0K
VGhlIGZhc3Qgc3lzdGVtIGNhbGwgcGF0aCBoYXMgYSB3aG9sZSBob3N0IG9mIHNlcmlvdXMgcmVz
dHJpY3Rpb25zIG9uIHdoYXQgaXQgY2FuDQp0b3VjaC4gU2VlIERvY3VtZW50YXRpb24vaWE2NC9m
c3lzLnR4dC4gIFdoeSBpcyBnZXRwaWQoKSBhIGZhc3Qgc3lzdGVtIGNhbGw/IEkgdGhpbmsNCnRo
ZXJlIHdhcyBzb21lIGFwcGxpY2F0aW9uIChvciBwZXJoYXBzIGJlbmNobWFyaykgdGhhdCB1c2Vk
IGl0IGEgbG90Lg0KDQo+ICAgICAgICBhZGQgcjg9SUE2NF9QSURfTEVWRUxfT0ZGU0VULHIxNw0K
PiAgICAgICAgOzsNCj4gICAgICAgIGxkNCByOD1bcjhdICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAvLyByOCA9IHBpZC0+bGV2ZWwNCj4gICAgICAgIGFkZCByMTc9SUE2NF9QSURfVVBJRF9P
RkZTRVQscjE3ICAgICAgICAvLyByMTcgPSAmcGlkLT5udW1iZXJzWzBdDQo+ICAgICAgICA7Ow0K
PiAgICAgICAgc2hsIHI4PXI4LElBNjRfVVBJRF9TSElGVA0KPiAgICAgICAgOzsNCj4gICAgICAg
IGFkZCByMTc9cjE3LHI4ICAgICAgICAgICAgICAgICAgICAgICAgICAvLyByMTcgPSAmcGlkLT5u
dW1iZXJzW3BpZC0+bGV2ZWxdDQo+ICAgICAgICA7Ow0KPiAgICAgICAgbGQ0IHI4PVtyMTddICAg
ICAgICAgICAgICAgICAgICAgICAgICAgIC8vIHI4ID0gcGlkLT5udW1iZXJzW3BpZC0+bGV2ZWxd
Lm5yDQo+ICAgICAgICA7Ow0KPiAgICAgICAgbW92IHIxNz0wDQo+DQo+IEx1Y2tpbHkgaXQgbG9v
a3MgbGlrZSB0aGlzIGlzIG9ubHkgcmVmZXJlbmNpbmcgdGhlIGZpcnN0IG1lbWJlcnMgb2Ygc3Ry
dWN0IHVwaWQsDQo+IGFuZCB5b3UgYXJlIHJlbW92aW5nIHRoZSBsYXN0IG1lbWJlciwgc28gSSBz
dXNwZWN0IHlvdSB3aWxsIGJlIGZpbmUgY2hhbmdpbmcgdGhlIElBNjQNCj4gdG8gdGhpczoNCj4N
Cj7CoMKgwqDCoMKgwqDCoMKgQlVJTERfQlVHX09OKHNpemVvZihzdHJ1Y3QgdXBpZCkgIT0gMTYp
Ow0KPsKgwqDCoMKgwqDCoMKgwqBERUZJTkUoSUE2NF9VUElEX1NISUZULCA0KTsNCj4NCj4gVG9u
eSwgZG9lcyB0aGF0IGxvb2sgb2sgdG8geW91Pw0KDQpJIHRoaW5rIHNvLiAgUmVzcGluIGFuZCBD
YzogbWUgb24gYm90aCBwYXRjaGVzIGluIHRoZSBzZXJpZXMgYW5kIEknbGwgdGFrZSBpdCBmb3Ig
YSBzcGluDQpvbiBoL3cgdG8gbWFrZSBzdXJlLg0KDQotVG9ueQ0K
