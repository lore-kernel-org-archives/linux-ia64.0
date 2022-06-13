From: Peter Zijlstra <peterz@infradead.org>
Date: Mon, 13 Jun 2022 08:41:27 +0000
Subject: Re: [PATCH 21/36] x86/tdx: Remove TDX_HCALL_ISSUE_STI
Message-Id: <Yqb4N3iwh1X7378o@hirez.programming.kicks-ass.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220608142723.103523089@infradead.org>
 <20220608144517.251109029@infradead.org>
 <CAJhGHyCnu_BsKf5STMMJKMWm0NVZ8qXT8Qh=BhhCjSSgwchL3Q@mail.gmail.com>
In-Reply-To: <CAJhGHyCnu_BsKf5STMMJKMWm0NVZ8qXT8Qh=BhhCjSSgwchL3Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Lai Jiangshan <jiangshanlai@gmail.com>
Cc: Richard Henderson <rth@twiddle.net>, ink@jurassic.park.msu.ru, mattst88@gmail.com, vgupta@kernel.org, linux@armlinux.org.uk, ulli.kroll@googlemail.com, linus.walleij@linaro.org, shawnguo@kernel.org, Sascha Hauer <s.hauer@pengutronix.de>, kernel@pengutronix.de, festevam@gmail.com, linux-imx@nxp.com, tony@atomide.com, khilman@kernel.org, catalin.marinas@arm.com, Will Deacon <will@kernel.org>, guoren@kernel.org, bcain@quicinc.com, Huacai Chen <chenhuacai@kernel.org>, kernel@xen0n.name, geert@linux-m68k.org, sammy@sammy.net, monstr@monstr.eu, tsbogend@alpha.franken.de, dinguyen@kernel.org, jonas@southpole.se, stefan.kristiansson@saunalahti.fi, shorne@gmail.com, James.Bottomley@hansenpartnership.com, deller@gmx.de, Michael Ellerman <mpe@ellerman.id.au>, benh@kernel.crashing.org, paulus@samba.org, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, hca@linux.ibm.com, gor@linux.ibm.com, agordeev@linux.ibm.com, borntraeger@linux.ibm.com, svens@linux.ibm.com, ysato@users.sourceforge.jp, dalias@libc.org, davem@davemloft.net, Richard Weinberger <richard@nod.at>, anton.ivanov@cambridgegreys.com, Johannes Berg <johannes@sipsolutions.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, acme <acme@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, jolsa@kernel.org, Namhyung Kim <namhyung@kernel.org>, Juergen Gross <jgross@suse.com>, srivatsa@csail.mit.edu, amakhalov@vmware.com, VMware Inc <pv-drivers@vmware.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, chris@zankel.net, jcmvbkbc@gmail.com, rafael@kernel.org, lenb@kernel.org, pavel@ucw.cz, gregkh@linuxfoundation.org, mturquette@baylibre.com, sboyd@kernel.org, daniel.lezcano@linaro.org, lpieralisi@kernel.org, sudeep.holla@arm.com, agross@kernel.org, bjorn.andersson@linaro.org, Anup Patel <anup@brainfault.org>, thierry.reding@gmail.com, jonathanh@nvidia.com, jacob.jun.pan@linux.intel.com, Arnd Bergmann <arnd@arndb.de>, yury.norov@gmail.com, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, linux@rasmusvillemoes.dk, rostedt@goodmis.org, pmladek@suse.com, senozhatsky@chromium.org, john.ogness@linutronix.de, paulmck@kernel.org, frederic@kernel.org, quic_neeraju@quicinc.com, josh@joshtriplett.org, mathieu.desnoyers@efficios.com, joel@joelfernandes.org, juri.lelli@redhat.com, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, bsegall@google.com, mgorman@suse.de, bristot@redhat.com, vschneid@redhat.com, jpoimboe@kernel.org, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-um@lists.infradead.org, linux-perf-users@vger.kernel.org, virtualization@lists.linux-foundation.org, xen-devel@lists.xenproject.org, linux-xtensa@linux-xtensa.org, linux-acpi@vger.kernel.org, linux-pm@vger.kernel.org, linux-clk@vger.kernel.org, linux-arm-msm@vger.kernel.org, linux-tegra@vger.kernel.org, linux-arch@vger.kernel.org, rcu@vger.kernel.org, Isaku Yamahata <isaku.yamahata@gmail.com>, kirill.shutemov@linux.intel.com

On Mon, Jun 13, 2022 at 04:26:01PM +0800, Lai Jiangshan wrote:
> On Wed, Jun 8, 2022 at 10:48 PM Peter Zijlstra <peterz@infradead.org> wro=
te:
> >
> > Now that arch_cpu_idle() is expected to return with IRQs disabled,
> > avoid the useless STI/CLI dance.
> >
> > Per the specs this is supposed to work, but nobody has yet relied up
> > this behaviour so broken implementations are possible.
>=20
> I'm totally newbie here.
>=20
> The point of safe_halt() is that STI must be used and be used
> directly before HLT to enable IRQ during the halting and stop
> the halting if there is any IRQ.

Correct; on real hardware. But this is virt...

> In TDX case, STI must be used directly before the hypercall.
> Otherwise, no IRQ can come and the vcpu would be stalled forever.
>=20
> Although the hypercall has an "irq_disabled" argument.
> But the hypervisor doesn't (and can't) touch the IRQ flags no matter
> what the "irq_disabled" argument is.  The IRQ is not enabled during
> the halting if the IRQ is disabled before the hypercall even if
> irq_disabled=FAlse.

All we need the VMM to do is wake the vCPU, and it can do that,
irrespective of the guest's IF.

So the VMM can (and does) know if there's an interrupt pending, and
that's all that's needed to wake from this hypercall. Once the vCPU is
back up and running again, we'll eventually set IF again and the pending
interrupt will get delivered and all's well.

Think of this like MWAIT with ECX[0] set if you will.
