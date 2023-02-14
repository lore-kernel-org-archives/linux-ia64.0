From: =?UTF-8?Q?Philippe_Mathieu-Daud=c3=a9?= <philmd@linaro.org>
Date: Tue, 14 Feb 2023 07:50:33 +0000
Subject: Re: [PATCH v2 10/24] mips/cpu: Make sure play_dead() doesn't return
Message-Id: <c302c616-8c8d-0da1-c334-4d77cf2120bf@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1676358308.git.jpoimboe@kernel.org>
 <b195e4da190bb06b7d4af15d66ce6129e2347630.1676358308.git.jpoimboe@kernel.org>
In-Reply-To: <b195e4da190bb06b7d4af15d66ce6129e2347630.1676358308.git.jpoimboe@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="macroman"
Content-Transfer-Encoding: base64
To: Josh Poimboeuf <jpoimboe@kernel.org>, linux-kernel@vger.kernel.org
Cc: jgross@suse.com, richard.henderson@linaro.org, ink@jurassic.park.msu.ru, mattst88@gmail.com, linux-alpha@vger.kernel.org, linux@armlinux.org.uk, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, will@kernel.org, guoren@kernel.org, linux-csky@vger.kernel.org, linux-ia64@vger.kernel.org, chenhuacai@kernel.org, kernel@xen0n.name, loongarch@lists.linux.dev, f.fainelli@gmail.com, bcm-kernel-feedback-list@broadcom.com, tsbogend@alpha.franken.de, linux-mips@vger.kernel.org, jiaxun.yang@flygoat.com, mpe@ellerman.id.au, npiggin@gmail.com, christophe.leroy@csgroup.eu, linuxppc-dev@lists.ozlabs.org, ysato@users.sourceforge.jp, dalias@libc.org, linux-sh@vger.kernel.org, davem@davemloft.net, sparclinux@vger.kernel.org, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, x86@kernel.org, hpa@zytor.com, chris@zankel.net, jcmvbkbc@gmail.com, linux-xtensa@linux-xtensa.org, peterz@infradead.org, juri.lelli@redhat.com, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, bsegall@google.com, mgorman@suse.de, bristot@redhat.com, vschneid@redhat.com, paulmck@kernel.org

T24gMTQvMi8yMyAwODowNSwgSm9zaCBQb2ltYm9ldWYgd3JvdGU6Cj4gcGxheV9kZWFkKCkgZG9l
c24ndCByZXR1cm4uICBNYWtlIHRoYXQgbW9yZSBleHBsaWNpdCB3aXRoIGEgQlVHKCkuCj4gCj4g
QlVHKCkgaXMgcHJlZmVyYWJsZSB0byB1bnJlYWNoYWJsZSgpIGJlY2F1c2UgQlVHKCkgaXMgYSBt
b3JlIGV4cGxpY2l0Cj4gZmFpbHVyZSBtb2RlIGFuZCBhdm9pZHMgdW5kZWZpbmVkIGJlaGF2aW9y
IGxpa2UgZmFsbGluZyBvZmYgdGhlIGVkZ2Ugb2YKPiB0aGUgZnVuY3Rpb24gaW50byB3aGF0ZXZl
ciBjb2RlIGhhcHBlbnMgdG8gYmUgbmV4dC4KPiAKPiBBY2tlZC1ieTogRmxvcmlhbiBGYWluZWxs
aSA8Zi5mYWluZWxsaUBnbWFpbC5jb20+Cj4gU2lnbmVkLW9mZi1ieTogSm9zaCBQb2ltYm9ldWYg
PGpwb2ltYm9lQGtlcm5lbC5vcmc+Cj4gLS0tCj4gICBhcmNoL21pcHMva2VybmVsL3NtcC1ibWlw
cy5jIHwgMiArKwo+ICAgYXJjaC9taXBzL2xvb25nc29uNjQvc21wLmMgICB8IDEgKwo+ICAgMiBm
aWxlcyBjaGFuZ2VkLCAzIGluc2VydGlvbnMoKykKClJldmlld2VkLWJ5OiBQaGlsaXBwZSBNYXRo
aWV1LURhdWTDqSA8cGhpbG1kQGxpbmFyby5vcmc+Cg==
