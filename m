From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Sat, 30 Jul 2022 19:52:34 +0000
Subject: Re: [PATCH 04/36] cpuidle,intel_idle: Fix CPUIDLE_FLAG_IRQ_ENABLE
Message-Id: <CAJZ5v0hXVjsWab=qYZfXBTqcjkpWV0CFT9_oQBKQ28rFG3_VLw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220608142723.103523089@infradead.org> <20220608144516.172460444@infradead.org>
 <20220725194306.GA14746@lespinasse.org> <20220728172053.GA3607379@paulmck-ThinkPad-P17-Gen-1>
 <20220729102458.GA1695@lespinasse.org> <CAJZ5v0gyPtX=ksCibo2ZN_BztCqUn9KRtRu+gsJ5KetB_1MwEQ@mail.gmail.com>
 <20220730094800.GB1587@lespinasse.org>
In-Reply-To: <20220730094800.GB1587@lespinasse.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="macroman"
Content-Transfer-Encoding: base64
To: Michel Lespinasse <michel@lespinasse.org>
Cc: "Rafael J. Wysocki" <rafael@kernel.org>, "Paul E. McKenney" <paulmck@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, vgupta@kernel.org, Russell King - ARM Linux <linux@armlinux.org.uk>, ulli.kroll@googlemail.com, Linus Walleij <linus.walleij@linaro.org>, Shawn Guo <shawnguo@kernel.org>, Sascha Hauer <s.hauer@pengutronix.de>, Sascha Hauer <kernel@pengutronix.de>, Fabio Estevam <festevam@gmail.com>, dl-linux-imx <linux-imx@nxp.com>, Tony Lindgren <tony@atomide.com>, Kevin Hilman <khilman@kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Guo Ren <guoren@kernel.org>, bcain@quicinc.com, Huacai Chen <chenhuacai@kernel.org>, kernel@xen0n.name, Geert Uytterhoeven <geert@linux-m68k.org>, sammy@sammy.net, Michal Simek <monstr@monstr.eu>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, dinguyen@kernel.org, jonas@southpole.se, stefan.kristiansson@saunalahti.fi, Stafford Horne <shorne@gmail.com>, James Bottomley <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Heiko Carstens <hca@linux.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Alexander Gordeev <agordeev@linux.ibm.com>, Christian Borntraeger <borntraeger@linux.ibm.com>, Sven Schnelle <svens@linux.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, David Miller <davem@davemloft.net>, Richard Weinberger <richard@nod.at>, anton.ivanov@cambridgegreys.com, Johannes Berg <johannes@sipsolutions.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, the arch/x86 maintainers <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, acme@kernel.org, Mark Rutland <mark.rutland@arm.com>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, jolsa@kernel.org, namhyung@kernel.org, Juergen Gross <jgross@suse.com>, srivatsa@csail.mit.edu, amakhalov@vmware.com, pv-drivers@vmware.com, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, Len Brown <lenb@kernel.org>, Pavel Machek <pavel@ucw.cz>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Michael Turquette <mturquette@baylibre.com>, Stephen Boyd <sboyd@kernel.org>, Daniel Lezcano <daniel.lezcano@linaro.org>, Lorenzo Pieralisi <lpieralisi@kernel.org>, Sudeep Holla <sudeep.holla@arm.com>, Andy Gross <agross@kernel.org>, Bjorn Andersson <bjorn.andersson@linaro.org>, Anup Patel <anup@brainfault.org>, Thierry Reding <thierry.reding@gmail.com>, Jon Hunter <jonathanh@nvidia.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, Arnd Bergmann <arnd@arndb.de>, Yury Norov <yury.norov@gmail.com>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Steven Rostedt <rostedt@goodmis.org>, Petr Mladek <pmladek@suse.com>, senozhatsky@chromium.org, John Ogness <john.ogness@linutronix.de>, Frederic Weisbecker <frederic@kernel.org>, quic_neeraju@quicinc.com, Josh Triplett <josh@joshtriplett.org>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Lai Jiangshan <jiangshanlai@gmail.com>, Joel Fernandes <joel@joelfernandes.org>, Juri Lelli <juri.lelli@redhat.com>, Vincent Guittot <vincent.guittot@linaro.org>, Dietmar Eggemann <dietmar.eggemann@arm.com>, Benjamin Segall <bsegall@google.com>, Mel Gorman <mgorman@suse.de>, Daniel Bristot de Oliveira <bristot@redhat.com>, vschneid@redhat.com, jpoimboe@kernel.org, linux-alpha@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-snps-arc@lists.infradead.org, Linux ARM <linux-arm-kernel@lists.infradead.org>, Linux OMAP Mailing List <linux-omap@vger.kernel.org>, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k <linux-m68k@lists.linux-m68k.org>, "open list:BROADCOM NVRAM DRIVER" <linux-mips@vger.kernel.org>, openrisc@lists.librecores.org, Parisc List <linux-parisc@vger.kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-riscv <linux-riscv@lists.infradead.org>, linux-s390@vger.kernel.org, Linux-sh list <linux-sh@vger.kernel.org>, sparclinux@vger.kernel.org, linux-um@lists.infradead.org, linux-perf-users@vger.kernel.org, virtualization@lists.linux-foundation.org, xen-devel@lists.xenproject.org, linux-xtensa@linux-xtensa.org, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, Linux PM <linux-pm@vger.kernel.org>, linux-clk <linux-clk@vger.kernel.org>, linux-arm-msm <linux-arm-msm@vger.kernel.org>, linux-tegra <linux-tegra@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, rcu@vger.kernel.org, rh0@fb.com

T24gU2F0LCBKdWwgMzAsIDIwMjIgYXQgMTE6NDggQU0gTWljaGVsIExlc3BpbmFzc2UKPG1pY2hl
bEBsZXNwaW5hc3NlLm9yZz4gd3JvdGU6Cj4KPiBPbiBGcmksIEp1bCAyOSwgMjAyMiBhdCAwNDo1
OTo1MFBNICswMjAwLCBSYWZhZWwgSi4gV3lzb2NraSB3cm90ZToKPiA+IE9uIEZyaSwgSnVsIDI5
LCAyMDIyIGF0IDEyOjI1IFBNIE1pY2hlbCBMZXNwaW5hc3NlCj4gPiA8bWljaGVsQGxlc3BpbmFz
c2Uub3JnPiB3cm90ZToKPiA+ID4KPiA+ID4gT24gVGh1LCBKdWwgMjgsIDIwMjIgYXQgMTA6MjA6
NTNBTSAtMDcwMCwgUGF1bCBFLiBNY0tlbm5leSB3cm90ZToKPiA+ID4gPiBPbiBNb24sIEp1bCAy
NSwgMjAyMiBhdCAxMjo0MzowNlBNIC0wNzAwLCBNaWNoZWwgTGVzcGluYXNzZSB3cm90ZToKPiA+
ID4gPiA+IE9uIFdlZCwgSnVuIDA4LCAyMDIyIGF0IDA0OjI3OjI3UE0gKzAyMDAsIFBldGVyIFpp
amxzdHJhIHdyb3RlOgo+ID4gPiA+ID4gPiBDb21taXQgYzIyNzIzM2FkNjRjICgiaW50ZWxfaWRs
ZTogZW5hYmxlIGludGVycnVwdHMgYmVmb3JlIEMxIG9uCj4gPiA+ID4gPiA+IFhlb25zIikgd3Jl
Y2tlZCBpbnRlbF9pZGxlIGluIHR3byB3YXlzOgo+ID4gPiA+ID4gPgo+ID4gPiA+ID4gPiAgLSBt
dXN0IG5vdCBoYXZlIHRyYWNpbmcgaW4gaWRsZSBmdW5jdGlvbnMKPiA+ID4gPiA+ID4gIC0gbXVz
dCByZXR1cm4gd2l0aCBJUlFzIGRpc2FibGVkCj4gPiA+ID4gPiA+Cj4gPiA+ID4gPiA+IEFkZGl0
aW9uYWxseSwgaXQgYWRkZWQgYSBicmFuY2ggZm9yIG5vIGdvb2QgcmVhc29uLgo+ID4gPiA+ID4g
Pgo+ID4gPiA+ID4gPiBGaXhlczogYzIyNzIzM2FkNjRjICgiaW50ZWxfaWRsZTogZW5hYmxlIGlu
dGVycnVwdHMgYmVmb3JlIEMxIG9uIFhlb25zIikKPiA+ID4gPiA+ID4gU2lnbmVkLW9mZi1ieTog
UGV0ZXIgWmlqbHN0cmEgKEludGVsKSA8cGV0ZXJ6QGluZnJhZGVhZC5vcmc+Cj4gPiA+ID4gPgo+
ID4gPiA+ID4gQWZ0ZXIgdGhpcyBjaGFuZ2Ugd2FzIGludHJvZHVjZWQsIEkgYW0gc2VlaW5nICJX
QVJOSU5HOiBzdXNwaWNpb3VzIFJDVQo+ID4gPiA+ID4gdXNhZ2UiIHdoZW4gYm9vdGluZyBhIGtl
cm5lbCB3aXRoIGRlYnVnIG9wdGlvbnMgY29tcGlsZWQgaW4uIFBsZWFzZQo+ID4gPiA+ID4gc2Vl
IHRoZSBhdHRhY2hlZCBkbWVzZyBvdXRwdXQuIFRoZSBpc3N1ZSBzdGFydHMgd2l0aCBjb21taXQg
MzJkNGZkNTc1MWVhCj4gPiA+ID4gPiBhbmQgaXMgc3RpbGwgcHJlc2VudCBpbiB2NS4xOS1yYzgu
Cj4gPiA+ID4gPgo+ID4gPiA+ID4gSSdtIG5vdCBzdXJlLCBpcyB0aGlzIHRvbyBsYXRlIHRvIGZp
eCBvciByZXZlcnQgaW4gdjUuMTkgZmluYWwgPwo+ID4gPiA+Cj4gPiA+ID4gSSBmaW5hbGx5IGdv
dCBhIGNoYW5jZSB0byB0YWtlIGEgcXVpY2sgbG9vayBhdCB0aGlzLgo+ID4gPiA+Cj4gPiA+ID4g
VGhlIHJjdV9lcXNfZXhpdCgpIGZ1bmN0aW9uIGlzIG1ha2luZyBhIGxvY2tkZXAgY29tcGxhaW50
IGFib3V0Cj4gPiA+ID4gYmVpbmcgaW52b2tlZCB3aXRoIGludGVycnVwdHMgZW5hYmxlZC4gIFRo
aXMgZnVuY3Rpb24gaXMgY2FsbGVkIGZyb20KPiA+ID4gPiByY3VfaWRsZV9leGl0KCksIHdoaWNo
IGlzIGFuIGV4cGVjdGVkIGNvZGUgcGF0aCBmcm9tIGNwdWlkbGVfZW50ZXJfc3RhdGUoKQo+ID4g
PiA+IHZpYSBpdHMgY2FsbCB0byByY3VfaWRsZV9leGl0KCkuICBFeGNlcHQgdGhhdCByY3VfaWRs
ZV9leGl0KCkgZGlzYWJsZXMKPiA+ID4gPiBpbnRlcnJ1cHRzIGJlZm9yZSBpbnZva2luZyByY3Vf
ZXFzX2V4aXQoKS4KPiA+ID4gPgo+ID4gPiA+IFRoZSBvbmx5IG90aGVyIGNhbGwgdG8gcmN1X2lk
bGVfZXhpdCgpIGRvZXMgbm90IGRpc2FibGUgaW50ZXJydXB0cywKPiA+ID4gPiBidXQgaXQgaXMg
dmlhIHJjdV91c2VyX2V4aXQoKSwgd2hpY2ggd291bGQgYmUgYSB2ZXJ5IG9kZCBjaG9pY2UgZm9y
Cj4gPiA+ID4gY3B1aWRsZV9lbnRlcl9zdGF0ZSgpLgo+ID4gPiA+Cj4gPiA+ID4gSXQgc2VlbXMg
dW5saWtlbHksIGJ1dCBpdCBtaWdodCBiZSB0aGF0IGl0IGlzIHRoZSB1c2Ugb2YgbG9jYWxfaXJx
X3NhdmUoKQo+ID4gPiA+IGluc3RlYWQgb2YgcmF3X2xvY2FsX2lycV9zYXZlKCkgd2l0aGluIHJj
dV9pZGxlX2V4aXQoKSB0aGF0IGlzIGNhdXNpbmcKPiA+ID4gPiB0aGUgdHJvdWJsZS4gIElmIHRo
aXMgaXMgdGhlIGNhc2UsIHRoZW4gdGhlIGNvbW1pdCBzaG93biBiZWxvdyB3b3VsZAo+ID4gPiA+
IGhlbHAuICBOb3RlIHRoYXQgdGhpcyBjb21taXQgcmVtb3ZlcyB0aGUgd2FybmluZyBmcm9tIGxv
Y2tkZXAsIHNvIGl0Cj4gPiA+ID4gaXMgbmVjZXNzYXJ5IHRvIGJ1aWxkIHRoZSBrZXJuZWwgd2l0
aCBDT05GSUdfUkNVX0VRU19ERUJVRz15IHRvIGVuYWJsZQo+ID4gPiA+IGVxdWl2YWxlbnQgZGVi
dWdnaW5nLgo+ID4gPiA+Cj4gPiA+ID4gQ291bGQgeW91IHBsZWFzZSB0cnkgeW91ciB0ZXN0IHdp
dGggdGhlIC1yY2UgY29tbWl0IHNob3duIGJlbG93IGFwcGxpZWQ/Cj4gPiA+Cj4gPiA+IFRoYW5r
cyBmb3IgbG9va2luZyBpbnRvIGl0Lgo+ID4gPgo+ID4gPiBBZnRlciBjaGVja2luZyBvdXQgUGV0
ZXIncyBjb21taXQgMzJkNGZkNTc1MWVhLAo+ID4gPiBjaGVycnkgcGlja2luZyB5b3VyIGNvbW1p
dCBlZDRhZTVlZmY0YjMsCj4gPiA+IGFuZCBzZXR0aW5nIENPTkZJR19SQ1VfRVFTX0RFQlVHPXkg
aW4gYWRkaXRpb24gb2YgbXkgdXN1YWwgZGVidWcgY29uZmlnLAo+ID4gPiBJIGFtIG5vdyBzZWVp
bmcgdGhpcyBhIGZldyBzZWNvbmRzIGludG8gdGhlIGJvb3Q6Cj4gPiA+Cj4gPiA+IFsgICAgMy4w
MTA2NTBdIC0tLS0tLS0tLS0tLVsgY3V0IGhlcmUgXS0tLS0tLS0tLS0tLQo+ID4gPiBbICAgIDMu
MDEwNjUxXSBXQVJOSU5HOiBDUFU6IDAgUElEOiAwIGF0IGtlcm5lbC9zY2hlZC9jbG9jay5jOjM5
NyBzY2hlZF9jbG9ja190aWNrKzB4MjcvMHg2MAo+ID4gPiBbICAgIDMuMDEwNjU3XSBNb2R1bGVz
IGxpbmtlZCBpbjoKPiA+ID4gWyAgICAzLjAxMDY2MF0gQ1BVOiAwIFBJRDogMCBDb21tOiBzd2Fw
cGVyLzAgTm90IHRhaW50ZWQgNS4xOS4wLXJjMS10ZXN0LTAwMDA1LWcxYmUyMmZlYTA2MTEgIzEK
PiA+ID4gWyAgICAzLjAxMDY2Ml0gSGFyZHdhcmUgbmFtZTogTEVOT1ZPIDMwQkZTNDREMDAvMTAz
NiwgQklPUyBTMDNLVDUxQSAwMS8xNy8yMDIyCj4gPiA+IFsgICAgMy4wMTA2NjNdIFJJUDogMDAx
MDpzY2hlZF9jbG9ja190aWNrKzB4MjcvMHg2MAo+ID4gPiBbICAgIDMuMDEwNjY1XSBDb2RlOiAx
ZiA0MCAwMCA1MyBlYiAwMiA1YiBjMyA2NiA5MCA4YiAwNSAyZiBjMyA0MCAwMSA4NSBjMCA3NCAx
OCA2NSA4YiAwNSA2MCA4OCA4ZiA0ZSA4NSBjMCA3NSAwZCA2NSA4YiAwNSBhOSA4NSA4ZiA0ZSA4
NSBjMCA3NCAwMiA8MGY+IDBiIGU4IGUyIDZjIDg5IDAwIDQ4IGM3IGMzIDQwIGQ1IDAyIDAwCj4g
PiA+ICA4OSBjMCA0OCAwMyAxYyBjNSBjMCA5OAo+ID4gPiBbICAgIDMuMDEwNjY3XSBSU1A6IDAw
MDA6ZmZmZmZmZmZiMjgwM2UyOCBFRkxBR1M6IDAwMDEwMDAyCj4gPiA+IFsgICAgMy4wMTA2NzBd
IFJBWDogMDAwMDAwMDAwMDAwMDAwMSBSQlg6IGZmZmZjOGNlN2ZhMDcwNjAgUkNYOiAwMDAwMDAw
MDAwMDAwMDAxCj4gPiA+IFsgICAgMy4wMTA2NzFdIFJEWDogMDAwMDAwMDAwMDAwMDAwMCBSU0k6
IGZmZmZmZmZmYjI2OGRkMjEgUkRJOiBmZmZmZmZmZmIyNjlhYjEzCj4gPiA+IFsgICAgMy4wMTA2
NzNdIFJCUDogMDAwMDAwMDAwMDAwMDAwMSBSMDg6IGZmZmZmZmZmZmZjMzAwZDUgUjA5OiAwMDAw
MDAwMDAwMDJiZTgwCj4gPiA+IFsgICAgMy4wMTA2NzRdIFIxMDogMDAwMDAzNjI1YjUzMTgzYSBS
MTE6IGZmZmZhMDEyYjgwMmI3YTQgUjEyOiBmZmZmZmZmZmIyYWE5ZTgwCj4gPiA+IFsgICAgMy4w
MTA2NzVdIFIxMzogZmZmZmZmZmZiMmFhOWUwMCBSMTQ6IDAwMDAwMDAwMDAwMDAwMDEgUjE1OiAw
MDAwMDAwMDAwMDAwMDAwCj4gPiA+IFsgICAgMy4wMTA2NzddIEZTOiAgMDAwMDAwMDAwMDAwMDAw
MCgwMDAwKSBHUzpmZmZmYTAxMmI4MDAwMDAwKDAwMDApIGtubEdTOjAwMDAwMDAwMDAwMDAwMDAK
PiA+ID4gWyAgICAzLjAxMDY3OF0gQ1M6ICAwMDEwIERTOiAwMDAwIEVTOiAwMDAwIENSMDogMDAw
MDAwMDA4MDA1MDAzMwo+ID4gPiBbICAgIDMuMDEwNjgwXSBDUjI6IGZmZmZhMDEyZjgxZmYwMDAg
Q1IzOiAwMDAwMDAwYzk5NjEyMDAxIENSNDogMDAwMDAwMDAwMDM3MDZmMAo+ID4gPiBbICAgIDMu
MDEwNjgxXSBEUjA6IDAwMDAwMDAwMDAwMDAwMDAgRFIxOiAwMDAwMDAwMDAwMDAwMDAwIERSMjog
MDAwMDAwMDAwMDAwMDAwMAo+ID4gPiBbICAgIDMuMDEwNjgyXSBEUjM6IDAwMDAwMDAwMDAwMDAw
MDAgRFI2OiAwMDAwMDAwMGZmZmUwZmYwIERSNzogMDAwMDAwMDAwMDAwMDQwMAo+ID4gPiBbICAg
IDMuMDEwNjgzXSBDYWxsIFRyYWNlOgo+ID4gPiBbICAgIDMuMDEwNjg1XSAgPFRBU0s+Cj4gPiA+
IFsgICAgMy4wMTA2ODhdICBjcHVpZGxlX2VudGVyX3N0YXRlKzB4YjcvMHg0YjAKPiA+ID4gWyAg
ICAzLjAxMDY5NF0gIGNwdWlkbGVfZW50ZXIrMHgyOS8weDQwCj4gPiA+IFsgICAgMy4wMTA2OTdd
ICBkb19pZGxlKzB4MWQ0LzB4MjEwCj4gPiA+IFsgICAgMy4wMTA3MDJdICBjcHVfc3RhcnR1cF9l
bnRyeSsweDE5LzB4MjAKPiA+ID4gWyAgICAzLjAxMDcwNF0gIHJlc3RfaW5pdCsweDExNy8weDFh
MAo+ID4gPiBbICAgIDMuMDEwNzA4XSAgYXJjaF9jYWxsX3Jlc3RfaW5pdCsweGEvMHgxMAo+ID4g
PiBbICAgIDMuMDEwNzExXSAgc3RhcnRfa2VybmVsKzB4NmQ4LzB4NmZmCj4gPiA+IFsgICAgMy4w
MTA3MTZdICBzZWNvbmRhcnlfc3RhcnR1cF82NF9ub192ZXJpZnkrMHhjZS8weGRiCj4gPiA+IFsg
ICAgMy4wMTA3MjhdICA8L1RBU0s+Cj4gPiA+IFsgICAgMy4wMTA3MjldIGlycSBldmVudCBzdGFt
cDogNDQxNzkKPiA+ID4gWyAgICAzLjAxMDczMF0gaGFyZGlycXMgbGFzdCAgZW5hYmxlZCBhdCAo
NDQxNzkpOiBbPGZmZmZmZmZmYjIwMDBjY2I+XSBhc21fc3lzdmVjX2FwaWNfdGltZXJfaW50ZXJy
dXB0KzB4MWIvMHgyMAo+ID4gPiBbICAgIDMuMDEwNzM0XSBoYXJkaXJxcyBsYXN0IGRpc2FibGVk
IGF0ICg0NDE3Nyk6IFs8ZmZmZmZmZmZiMjIwMDNmMD5dIF9fZG9fc29mdGlycSsweDNmMC8weDQ5
OAo+ID4gPiBbICAgIDMuMDEwNzM2XSBzb2Z0aXJxcyBsYXN0ICBlbmFibGVkIGF0ICg0NDE3OCk6
IFs8ZmZmZmZmZmZiMjIwMDMzMj5dIF9fZG9fc29mdGlycSsweDMzMi8weDQ5OAo+ID4gPiBbICAg
IDMuMDEwNzM4XSBzb2Z0aXJxcyBsYXN0IGRpc2FibGVkIGF0ICg0NDE3MSk6IFs8ZmZmZmZmZmZi
MTZjNzYwYj5dIGlycV9leGl0X3JjdSsweGFiLzB4ZjAKPiA+ID4gWyAgICAzLjAxMDc0MV0gLS0t
WyBlbmQgdHJhY2UgMDAwMDAwMDAwMDAwMDAwMCBdLS0tCj4gPgo+ID4gQ2FuIHlvdSBwbGVhc2Ug
Z2l2ZSB0aGlzIHBhdGNoIGEgZ286Cj4gPiBodHRwczovL3BhdGNod29yay5rZXJuZWwub3JnL3By
b2plY3QvbGludXgtcG0vcGF0Y2gvWXQvQXhQRmk4OG5lVzdXNUBlMTI2MzExLm1hbmNoZXN0ZXIu
YXJtLmNvbS8KPiA+ID8KPgo+IEkgdHJpZWQsIGJ1dCBpdCBkaWRuJ3QgY2hhbmdlIHRoZSBwaWN0
dXJlIGZvciBtZS4KPgo+IEknbSBub3Qgc3VyZSBpZiB0aGF0IHdhcyB0aGUgcGF0Y2ggeW91IG1l
YW50IHRvIHNlbmQgdGhvdWdoLCBhcyBpdAo+IHNlZW1zIGl0J3Mgb25seSBhZGRpbmcgYSB0cmFj
ZXBvaW50IHNvIHNob3VsZG4ndCBtYWtlIGFueSBkaWZmZXJlbmNlCj4gaWYgSSdtIG5vdCBhY3R1
YWxseSB1c2luZyB0aGUgdHJhY2Vwb2ludCA/CgpZb3UgYXJlIHJpZ2h0LCBpdCBsb29rcyBsaWtl
IEkgcGFzdGVkIGEgbGluayB0byBhIGRpZmZlcmVudCBwYXRjaCBieQptaXN0YWtlLiAgU29ycnkg
YWJvdXQgdGhhdC4KCkkgbWVhbnQgdGhpcyBvbmU6CgpodHRwczovL2dpdC5rZXJuZWwub3JnL3B1
Yi9zY20vbGludXgva2VybmVsL2dpdC9yYWZhZWwvbGludXgtcG0uZ2l0L2NvbW1pdC8/aD1wbSZp
ZNI5NWFkMzRmMjM2YzM1MTg2MzRmYjY0MDNkNGMwMTYwNDU2ZTQ3MAoKd2hpY2ggd2lsbCBhcHBl
YXIgaW4gdGhlIGZpbmFsIDUuMTku
