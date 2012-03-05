From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 05 Mar 2012 23:21:53 +0000
Subject: RE: [regression] Re: [PATCH 2/3] futex: Sanitize cmpxchg_futex_value_locked API
Message-Id: <3908561D78D1C84285E8C5FCA982C28F041A65@ORSMSX104.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20110307021127.GB31188@google.com>
 <alpine.LFD.2.00.1103082114270.2787@localhost6.localdomain6>
 <20110309112550.GA3050@google.com>
 <alpine.LFD.2.00.1103101948540.2787@localhost6.localdomain6>
 <20110311021654.GA26122@google.com> <20110311024851.GC26122@google.com>
 <20120305000112.GA27512@burratino>
In-Reply-To: <20120305000112.GA27512@burratino>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jonathan Nieder <jrnieder@gmail.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>
Cc: Michel Lespinasse <walken@google.com>, =?utf-8?B?w4ltZXJpYyBNYXNjaGlubw==?= <emeric.maschino@gmail.com>, Patrick Baggett <baggett.patrick@gmail.com>, Jakub Jelinek <jakub@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

PiBJdCBkb2Vzbid0IGxvb2sgbGlrZSB0aGUgcmV0dXJuIHZhbHVlIChyOCkgaXMgYWN0dWFsbHkg
YmVpbmcgc2V0IGJleW9uZA0KPiBpbml0aWFsaXplZCB0byAwLiBJZiB0aGVyZSBpcyBzb21lIGlh
NjQgaW5zdHJ1Y3Rpb24gdGhhdCBtb2RpZmllcyBpdCwgR0NDDQo+IGRvZXNuJ3Qga25vdyBhYm91
dCBpdCBmcm9tIHRoZSBpbmxpbmUgYXNzZW1ibHkgKHI4IGRvZXNuJ3QgYXBwZWFyIGluIHRoZQ0K
PiBpbnB1dHMvb3V0cHV0cyBsaXN0KS4gRnJvbSBsb29raW5nIGF0IHRoZSB4ODYgdmVyc2lvbiAo
YWdoLCBpbmxpbmUgYXNtIGlzDQo+IGhhcmQgdG8gcGFyc2UpLCBpdCBkb2VzIG1vZGlmeSB0aGUg
cmV0dXJuIHZhbHVlIGJhc2VkIG9uIHdoZXRoZXIgdGhlDQo+IGNvbXBhcmlzb24gd2FzIGEgc3Vj
Y2VzcyBvciBub3QsIGFuZCB0aGUgcmV0dXJuIHZhbHVlIGlzIGNlcnRhaW5seSB1c2VkIGJ5DQo+
IHRoZSBjYWxsZXJzLg0KDQpUaGUgY29tbWl0IGNvbW1lbnQgZm9yIHRoZSBjaGFuZ2UgbWFrZXMg
aXQgc291bmQgbGlrZSB0aGUgcmV0dXJuIHZhbHVlDQppcyBhbiBlcnJvciBjb2RlICgtRU5PU1lT
IGlmIHRoZSBmdW5jdGlvbiBpc24ndCBpbXBsZW1lbnRlZC9jb25maWd1cmVkOw0KLUVGQVVMVCBp
ZiB0aGUgdXNlciBhZGRyZXNzIGlzIGJvZ3VzKSAtIG9yIHplcm8gaWYgbm90aGluZyBiYWQgaGFw
cGVuZWQuDQoNCk5vdCAidGhlIGNvbXBhcmlzb24gd2FzIGEgc3VjY2VzcyBvciBub3QiLg0KDQpX
aGF0J3MgdGhlIHJlYWwgYW5zd2VyPyBUaGUgaWE2NCBjb2RlIGlzIHJldHVybmluZyAwIHJlZ2Fy
ZGxlc3Mgb2Ygd2hldGhlciB0aGUNCmNvbXBhcmUvZXhjaGFuZ2UgZm91bmQgdGhlIG9sZCB2YWx1
ZSBvciBub3QuICBJcyB0aGlzIGEgYmFkIGFzc3VtcHRpb24/DQoNCi1Ub255DQo