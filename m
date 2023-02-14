From: =?UTF-8?Q?Philippe_Mathieu-Daud=c3=a9?= <philmd@linaro.org>
Date: Tue, 14 Feb 2023 08:07:02 +0000
Subject: Re: [PATCH v2 06/24] ia64/cpu: Mark play_dead() __noreturn
Message-Id: <6c4fc38a-ba24-fff8-7bdd-b633a79200db@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1676358308.git.jpoimboe@kernel.org>
 <7575bb38417bd8bcb5be980443f99cab29319342.1676358308.git.jpoimboe@kernel.org>
In-Reply-To: <7575bb38417bd8bcb5be980443f99cab29319342.1676358308.git.jpoimboe@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="macroman"
Content-Transfer-Encoding: base64
To: Josh Poimboeuf <jpoimboe@kernel.org>, linux-kernel@vger.kernel.org
Cc: jgross@suse.com, richard.henderson@linaro.org, ink@jurassic.park.msu.ru, mattst88@gmail.com, linux-alpha@vger.kernel.org, linux@armlinux.org.uk, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, will@kernel.org, guoren@kernel.org, linux-csky@vger.kernel.org, linux-ia64@vger.kernel.org, chenhuacai@kernel.org, kernel@xen0n.name, loongarch@lists.linux.dev, f.fainelli@gmail.com, bcm-kernel-feedback-list@broadcom.com, tsbogend@alpha.franken.de, linux-mips@vger.kernel.org, jiaxun.yang@flygoat.com, mpe@ellerman.id.au, npiggin@gmail.com, christophe.leroy@csgroup.eu, linuxppc-dev@lists.ozlabs.org, ysato@users.sourceforge.jp, dalias@libc.org, linux-sh@vger.kernel.org, davem@davemloft.net, sparclinux@vger.kernel.org, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, x86@kernel.org, hpa@zytor.com, chris@zankel.net, jcmvbkbc@gmail.com, linux-xtensa@linux-xtensa.org, peterz@infradead.org, juri.lelli@redhat.com, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, bsegall@google.com, mgorman@suse.de, bristot@redhat.com, vschneid@redhat.com, paulmck@kernel.org

T24gMTQvMi8yMyAwODowNSwgSm9zaCBQb2ltYm9ldWYgd3JvdGU6Cj4gcGxheV9kZWFkKCkgZG9l
c24ndCByZXR1cm4uICBBbm5vdGF0ZSBpdCBhcyBzdWNoLiAgQnkgZXh0ZW5zaW9uIHRoaXMKPiBh
bHNvIG1ha2VzIGFyY2hfY3B1X2lkbGVfZGVhZCgpIG5vcmV0dXJuLgo+IAo+IFNpZ25lZC1vZmYt
Ynk6IEpvc2ggUG9pbWJvZXVmIDxqcG9pbWJvZUBrZXJuZWwub3JnPgo+IC0tLQo+ICAgYXJjaC9p
YTY0L2tlcm5lbC9wcm9jZXNzLmMgfCA0ICsrLS0KPiAgIDEgZmlsZSBjaGFuZ2VkLCAyIGluc2Vy
dGlvbnMoKyksIDIgZGVsZXRpb25zKC0pCgpSZXZpZXdlZC1ieTogUGhpbGlwcGUgTWF0aGlldS1E
YXVkw6kgPHBoaWxtZEBsaW5hcm8ub3JnPgo=
