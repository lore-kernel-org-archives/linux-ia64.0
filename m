From: =?UTF-8?Q?Philippe_Mathieu-Daud=c3=a9?= <philmd@linaro.org>
Date: Thu, 02 Mar 2023 10:55:52 +0000
Subject: Re: [PATCH v2.1 04/24] arm64/cpu: Mark cpu_die() __noreturn
Message-Id: <1a4df71c-3934-6956-4120-d6cf3fcf4ca9@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1676358308.git.jpoimboe@kernel.org>
 <e47fc487980d5330e6059ac6e16416bec88cda0e.1676358308.git.jpoimboe@kernel.org>
 <14274f04-2991-95bd-c29b-07e86e8755c1@linaro.org>
 <Y+zZgZIP7RPIgyQf@FVFF77S0Q05N> <20230215194538.aiiris3uabnuvkkg@treble>
 <20230216184157.4hup6y6mmspr2kll@treble>
In-Reply-To: <20230216184157.4hup6y6mmspr2kll@treble>
MIME-Version: 1.0
Content-Type: text/plain; charset="macroman"
Content-Transfer-Encoding: base64
To: Josh Poimboeuf <jpoimboe@kernel.org>, Mark Rutland <mark.rutland@arm.com>
Cc: juri.lelli@redhat.com, dalias@libc.org, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, peterz@infradead.org, catalin.marinas@arm.com, dave.hansen@linux.intel.com, x86@kernel.org, jiaxun.yang@flygoat.com, linux-mips@vger.kernel.org, bsegall@google.com, jcmvbkbc@gmail.com, guoren@kernel.org, hpa@zytor.com, sparclinux@vger.kernel.org, kernel@xen0n.name, will@kernel.org, vschneid@redhat.com, f.fainelli@gmail.com, vincent.guittot@linaro.org, ysato@users.sourceforge.jp, chenhuacai@kernel.org, linux@armlinux.org.uk, linux-csky@vger.kernel.org, dietmar.eggemann@arm.com, mingo@redhat.com, bcm-kernel-feedback-list@broadcom.com, mgorman@suse.de, mattst88@gmail.com, linux-xtensa@linux-xtensa.org, paulmck@kernel.org, richard.henderson@linaro.org, npiggin@gmail.com, ink@jurassic.park.msu.ru, rostedt@goodmis.org, loongarch@lists.linux.dev, tglx@linutronix.de, linux-arm-kernel@lists.infradead.org, jgross@suse.com, chris@zankel.net, tsbogend@alpha.franken.de, bristot@redhat.com, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, bp@alien8.de, linuxppc-dev@lists.ozlabs.org, davem@davemloft.net

T24gMTYvMi8yMyAxOTo0MSwgSm9zaCBQb2ltYm9ldWYgd3JvdGU6Cj4gY3B1X2RpZSgpIGRvZXNu
J3QgcmV0dXJuLiAgQW5ub3RhdGUgaXQgYXMgc3VjaC4gIEJ5IGV4dGVuc2lvbiB0aGlzIGFsc28K
PiBtYWtlcyBhcmNoX2NwdV9pZGxlX2RlYWQoKSBub3JldHVybi4KPiAKPiBBY2tlZC1ieTogTWFy
ayBSdXRsYW5kIDxtYXJrLnJ1dGxhbmRAYXJtLmNvbT4KPiBTaWduZWQtb2ZmLWJ5OiBKb3NoIFBv
aW1ib2V1ZiA8anBvaW1ib2VAa2VybmVsLm9yZz4KPiAtLS0KPiAgIGFyY2gvYXJtNjQvaW5jbHVk
ZS9hc20vc21wLmggfCAyICstCj4gICBhcmNoL2FybTY0L2tlcm5lbC9zbXAuYyAgICAgIHwgMiAr
LQo+ICAgMiBmaWxlcyBjaGFuZ2VkLCAyIGluc2VydGlvbnMoKyksIDIgZGVsZXRpb25zKC0pCgpS
ZXZpZXdlZC1ieTogUGhpbGlwcGUgTWF0aGlldS1EYXVkw6kgPHBoaWxtZEBsaW5hcm8ub3JnPgo=
