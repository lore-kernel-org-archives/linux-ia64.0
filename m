From: =?UTF-8?Q?Philippe_Mathieu-Daud=c3=a9?= <philmd@linaro.org>
Date: Tue, 14 Feb 2023 07:50:51 +0000
Subject: Re: [PATCH v2 11/24] mips/cpu: Mark play_dead() __noreturn
Message-Id: <56249307-5093-1283-d2db-26c5b20881fa@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1676358308.git.jpoimboe@kernel.org>
 <2897b51a9b8beb5b594fe66fb1d3a479ddd2a0e2.1676358308.git.jpoimboe@kernel.org>
In-Reply-To: <2897b51a9b8beb5b594fe66fb1d3a479ddd2a0e2.1676358308.git.jpoimboe@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="macroman"
Content-Transfer-Encoding: base64
To: Josh Poimboeuf <jpoimboe@kernel.org>, linux-kernel@vger.kernel.org
Cc: jgross@suse.com, richard.henderson@linaro.org, ink@jurassic.park.msu.ru, mattst88@gmail.com, linux-alpha@vger.kernel.org, linux@armlinux.org.uk, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, will@kernel.org, guoren@kernel.org, linux-csky@vger.kernel.org, linux-ia64@vger.kernel.org, chenhuacai@kernel.org, kernel@xen0n.name, loongarch@lists.linux.dev, f.fainelli@gmail.com, bcm-kernel-feedback-list@broadcom.com, tsbogend@alpha.franken.de, linux-mips@vger.kernel.org, jiaxun.yang@flygoat.com, mpe@ellerman.id.au, npiggin@gmail.com, christophe.leroy@csgroup.eu, linuxppc-dev@lists.ozlabs.org, ysato@users.sourceforge.jp, dalias@libc.org, linux-sh@vger.kernel.org, davem@davemloft.net, sparclinux@vger.kernel.org, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, x86@kernel.org, hpa@zytor.com, chris@zankel.net, jcmvbkbc@gmail.com, linux-xtensa@linux-xtensa.org, peterz@infradead.org, juri.lelli@redhat.com, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, bsegall@google.com, mgorman@suse.de, bristot@redhat.com, vschneid@redhat.com, paulmck@kernel.org

T24gMTQvMi8yMyAwODowNSwgSm9zaCBQb2ltYm9ldWYgd3JvdGU6Cj4gcGxheV9kZWFkKCkgZG9l
c24ndCByZXR1cm4uICBBbm5vdGF0ZSBpdCBhcyBzdWNoLiAgQnkgZXh0ZW5zaW9uIHRoaXMKPiBh
bHNvIG1ha2VzIGFyY2hfY3B1X2lkbGVfZGVhZCgpIG5vcmV0dXJuLgo+IAo+IEFja2VkLWJ5OiBG
bG9yaWFuIEZhaW5lbGxpIDxmLmZhaW5lbGxpQGdtYWlsLmNvbT4KPiBTaWduZWQtb2ZmLWJ5OiBK
b3NoIFBvaW1ib2V1ZiA8anBvaW1ib2VAa2VybmVsLm9yZz4KPiAtLS0KPiAgIGFyY2gvbWlwcy9p
bmNsdWRlL2FzbS9zbXAuaCB8IDIgKy0KPiAgIDEgZmlsZSBjaGFuZ2VkLCAxIGluc2VydGlvbigr
KSwgMSBkZWxldGlvbigtKQoKUmV2aWV3ZWQtYnk6IFBoaWxpcHBlIE1hdGhpZXUtRGF1ZMOpIDxw
aGlsbWRAbGluYXJvLm9yZz4KCg==
