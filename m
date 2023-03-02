From: =?UTF-8?Q?Philippe_Mathieu-Daud=c3=a9?= <philmd@linaro.org>
Date: Thu, 02 Mar 2023 10:54:58 +0000
Subject: Re: [PATCH v2.1 09/24] mips/cpu: Expose play_dead()'s prototype definition
Message-Id: <ecb9af84-a2a5-1414-13ea-be00e9203da3@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1676358308.git.jpoimboe@kernel.org>
 <39835bc75af2e812fce56400533cb2ab41bcf0e2.1676358308.git.jpoimboe@kernel.org>
 <080a5ccb-7fa0-1a75-538f-a09dc146fc4e@linaro.org>
 <20230214181101.3a2tscbmwdnwbqpu@treble>
 <c56dc4b9-035d-7773-ecb2-0e1ac6af7abc@linaro.org>
 <20230216184249.ogaqsaykottpxtcb@treble>
 <20230301181639.ajqdeh7g3m3fpqhk@treble>
In-Reply-To: <20230301181639.ajqdeh7g3m3fpqhk@treble>
MIME-Version: 1.0
Content-Type: text/plain; charset="macroman"
Content-Transfer-Encoding: base64
To: Josh Poimboeuf <jpoimboe@kernel.org>
Cc: linux-kernel@vger.kernel.org, jgross@suse.com, richard.henderson@linaro.org, ink@jurassic.park.msu.ru, mattst88@gmail.com, linux-alpha@vger.kernel.org, linux@armlinux.org.uk, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, will@kernel.org, guoren@kernel.org, linux-csky@vger.kernel.org, linux-ia64@vger.kernel.org, chenhuacai@kernel.org, kernel@xen0n.name, loongarch@lists.linux.dev, f.fainelli@gmail.com, bcm-kernel-feedback-list@broadcom.com, tsbogend@alpha.franken.de, linux-mips@vger.kernel.org, jiaxun.yang@flygoat.com, mpe@ellerman.id.au, npiggin@gmail.com, christophe.leroy@csgroup.eu, linuxppc-dev@lists.ozlabs.org, ysato@users.sourceforge.jp, dalias@libc.org, linux-sh@vger.kernel.org, davem@davemloft.net, sparclinux@vger.kernel.org, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, x86@kernel.org, hpa@zytor.com, chris@zankel.net, jcmvbkbc@gmail.com, linux-xtensa@linux-xtensa.org, peterz@infradead.org, juri.lelli@redhat.com, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, bsegall@google.com, mgorman@suse.de, bristot@redhat.com, vschneid@redhat.com, paulmck@kernel.org

T24gMS8zLzIzIDE5OjE2LCBKb3NoIFBvaW1ib2V1ZiB3cm90ZToKCj4gVGhlIGxhdGVzdCB2ZXJz
aW9uIG9mIHRoaXMgcGF0Y2ggdHJpZ2dlcmVkIGEgbmV3IGtidWlsZCB3YXJuaW5nIHdoaWNoIGlz
Cj4gZml4ZWQgYnkgdGhlIGJlbG93IHBhdGNoLiAgSWYgdGhlcmUgYXJlIG5vIG9iamVjdGlvbnMg
SSdsbCBidW5kbGUgaXQgaW4KPiB3aXRoIHRoZSByZXN0IG9mIHRoZSBzZXQgZm9yIG1lcmdpbmcu
Cj4gCj4gLS0tODwtLS0KPiAKPiBTdWJqZWN0OiBbUEFUQ0hdIG1pcHMvc21wOiBBZGQgQ09ORklH
X1NNUCBndWFyZCBmb3IgcmF3X3NtcF9wcm9jZXNzb3JfaWQoKQo+IENvbnRlbnQtdHlwZTogdGV4
dC9wbGFpbgo+IAo+IFdpdGhvdXQgQ09ORklHX1NNUCwgcmF3X3NtcF9wcm9jZXNzb3JfaWQoKSBp
cyBub3QgZXhwZWN0ZWQgdG8gYmUgZGVmaW5lZAo+IGJ5IHRoZSBhcmNoLgo+IAo+IFJlcG9ydGVk
LWJ5OiBrZXJuZWwgdGVzdCByb2JvdCA8bGtwQGludGVsLmNvbT4KPiBMaW5rOiBodHRwczovL2xv
cmUua2VybmVsLm9yZy9vZS1rYnVpbGQtYWxsLzIwMjMwMjIyMDc1NS5ITThKOEdPUi1sa3BAaW50
ZWwuY29tLwo+IFNpZ25lZC1vZmYtYnk6IEpvc2ggUG9pbWJvZXVmIDxqcG9pbWJvZUBrZXJuZWwu
b3JnPgo+IC0tLQo+ICAgYXJjaC9taXBzL2luY2x1ZGUvYXNtL3NtcC5oIHwgMiArKwo+ICAgMSBm
aWxlIGNoYW5nZWQsIDIgaW5zZXJ0aW9ucygrKQo+IAo+IGRpZmYgLS1naXQgYS9hcmNoL21pcHMv
aW5jbHVkZS9hc20vc21wLmggYi9hcmNoL21pcHMvaW5jbHVkZS9hc20vc21wLmgKPiBpbmRleCA0
ZWVlMjliNzg0NWMuLmNmOTkyYjhiMWU0NiAxMDA2NDQKPiAtLS0gYS9hcmNoL21pcHMvaW5jbHVk
ZS9hc20vc21wLmgKPiArKysgYi9hcmNoL21pcHMvaW5jbHVkZS9hc20vc21wLmgKPiBAQCAtMjUs
NiArMjUsNyBAQCBleHRlcm4gY3B1bWFza190IGNwdV9zaWJsaW5nX21hcFtdOwo+ICAgZXh0ZXJu
IGNwdW1hc2tfdCBjcHVfY29yZV9tYXBbXTsKPiAgIGV4dGVybiBjcHVtYXNrX3QgY3B1X2ZvcmVp
Z25fbWFwW107Cj4gICAKPiArI2lmZGVmIENPTkZJR19TTVAKPiAgIHN0YXRpYyBpbmxpbmUgaW50
IHJhd19zbXBfcHJvY2Vzc29yX2lkKHZvaWQpCj4gICB7Cj4gICAjaWYgZGVmaW5lZChfX1ZEU09f
XykKPiBAQCAtMzYsNiArMzcsNyBAQCBzdGF0aWMgaW5saW5lIGludCByYXdfc21wX3Byb2Nlc3Nv
cl9pZCh2b2lkKQo+ICAgI2VuZGlmCj4gICB9Cj4gICAjZGVmaW5lIHJhd19zbXBfcHJvY2Vzc29y
X2lkIHJhd19zbXBfcHJvY2Vzc29yX2lkCj4gKyNlbmRpZgo+ICAgCj4gICAvKiBNYXAgZnJvbSBj
cHUgaWQgdG8gc2VxdWVudGlhbCBsb2dpY2FsIGNwdSBudW1iZXIuICBUaGlzIHdpbGwgb25seQo+
ICAgICAgbm90IGJlIGlkZW1wb3RlbnQgd2hlbiBjcHVzIGZhaWxlZCB0byBjb21lIG9uLWxpbmUu
CSovCgpSZXZpZXdlZC1ieTogUGhpbGlwcGUgTWF0aGlldS1EYXVkw6kgPHBoaWxtZEBsaW5hcm8u
b3JnPgo=
