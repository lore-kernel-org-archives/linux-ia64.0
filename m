From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Date: Mon, 14 Feb 2022 18:00:26 +0000
Subject: Re: [PATCH 3/8] kernel/fork, IA64: Provide a alloc_thread_stack_node() for IA64.
Message-Id: <YgqYun8tmIJQZmuN@linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220125152652.1963111-1-bigeasy@linutronix.de>
 <20220125152652.1963111-4-bigeasy@linutronix.de>
In-Reply-To: <20220125152652.1963111-4-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1254"
Content-Transfer-Encoding: base64
To: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org
Cc: Andy Lutomirski <luto@kernel.org>, Ben Segall <bsegall@google.com>, Daniel Bristot de Oliveira <bristot@redhat.com>, Dietmar Eggemann <dietmar.eggemann@arm.com>, Ingo Molnar <mingo@redhat.com>, Juri Lelli <juri.lelli@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Thomas Gleixner <tglx@linutronix.de>, Vincent Guittot <vincent.guittot@linaro.org>

T24gMjAyMi0wMS0yNSAxNjoyNjo0NyBbKzAxMDBdLCBUbyBsaW51eC1rZXJuZWxAdmdlci5rZXJu
ZWwub3JnIHdyb3RlOgo+IGRpZmYgLS1naXQgYS9rZXJuZWwvZm9yay5jIGIva2VybmVsL2Zvcmsu
Ywo+IGluZGV4IGM0N2RjYmE1ZDY2ZDIuLmEwZDU4YWU2ZmFjNzYgMTAwNjQ0Cj4gLS0tIGEva2Vy
bmVsL2ZvcmsuYwo+ICsrKyBiL2tlcm5lbC9mb3JrLmMKPiBAQCAtMzMwLDYgKzMzMCwyMiBAQCB2
b2lkIHRocmVhZF9zdGFja19jYWNoZV9pbml0KHZvaWQpCuKApgo+ICAKPiArc3RhdGljIHZvaWQg
ZnJlZV90aHJlYWRfc3RhY2soc3RydWN0IHRhc2tfc3RydWN0ICp0c2ssIGJvb2wgY2FjaGVfb25s
eSkKClRoaXMgY2FjaGVfb25seSBwYXJhbWV0ZXIgc2hvdWxkbid0IGJlIGhlcmXigKYKCj4gK3sK
PiArCWFyY2hfZnJlZV90aHJlYWRfc3RhY2sodHNrKTsKPiArfQo+ICsKPiAgI2VuZGlmIC8qICFD
T05GSUdfQVJDSF9USFJFQURfU1RBQ0tfQUxMT0NBVE9SICovCj4gIAo+ICAvKiBTTEFCIGNhY2hl
IGZvciBzaWduYWxfc3RydWN0IHN0cnVjdHVyZXMgKHRzay0+c2lnbmFsKSAqLwoKU2ViYXN0aWFu
