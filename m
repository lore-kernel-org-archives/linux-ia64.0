From: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
Date: Thu, 07 Jun 2018 11:54:18 +0000
Subject: Re: [RFC PATCH -tip v5 24/27] bpf: error-inject: kprobes: Clear current_kprobe and enable preempt in
Message-Id: <1528371714.iz71qgzxv3.naveen@linux.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <152812730943.10068.5166429445118734697.stgit@devbox>
        <152812800822.10068.3306094708706993432.stgit@devbox>
In-Reply-To: <152812800822.10068.3306094708706993432.stgit@devbox>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masami Hiramatsu <mhiramat@kernel.org>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexei Starovoitov <ast@kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Fenghua Yu <fenghua.yu@intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, "H . Peter Anvin" <hpa@zytor.com>, Josef Bacik <jbacik@fb.com>, James Hogan <jhogan@kernel.org>, linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Russell King <linux@armlinux.org.uk>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-snps-arc@lists.infradead.org, Ingo Molnar <mingo@redhat.com>, Paul Mackerras <paulus@samba.org>, Ralf Baechle <ralf@l>

Masami Hiramatsu wrote:
> Clear current_kprobe and enable preemption in kprobe
> even if pre_handler returns !0.
> 
> This simplifies function override using kprobes.
> 
> Jprobe used to require to keep the preemption disabled and
> keep current_kprobe until it returned to original function
> entry. For this reason kprobe_int3_handler() and similar
> arch dependent kprobe handers checks pre_handler result
> and exit without enabling preemption if the result is !0.
> 
> After removing the jprobe, Kprobes does not need to
> keep preempt disabled even if user handler returns !0
> anymore.
> 
> But since the function override handler in error-inject
> and bpf is also returns !0 if it overrides a function,
> to balancing the preempt count, it enables preemption
> and reset current kprobe by itself.
> 
> That is a bad design that is very buggy. This fixes
> such unbalanced preempt-count and current_kprobes setting
> in kprobes, bpf and error-inject.
> 
> Note: for powerpc and x86, this removes all preempt_disable
> from kprobe_ftrace_handler because ftrace callbacks are
> called under preempt disabled.
> 
> Signed-off-by: Masami Hiramatsu <mhiramat@kernel.org>
> Cc: Vineet Gupta <vgupta@synopsys.com>
> Cc: Russell King <linux@armlinux.org.uk>
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: Tony Luck <tony.luck@intel.com>
> Cc: Fenghua Yu <fenghua.yu@intel.com>
> Cc: Ralf Baechle <ralf@linux-mips.org>
> Cc: James Hogan <jhogan@kernel.org>
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: Paul Mackerras <paulus@samba.org>
> Cc: Michael Ellerman <mpe@ellerman.id.au>
> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
> Cc: Rich Felker <dalias@libc.org>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
> Cc: Josef Bacik <jbacik@fb.com>
> Cc: Alexei Starovoitov <ast@kernel.org>
> Cc: x86@kernel.org
> Cc: linux-snps-arc@lists.infradead.org
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-arm-kernel@lists.infradead.org
> Cc: linux-ia64@vger.kernel.org
> Cc: linux-mips@linux-mips.org
> Cc: linuxppc-dev@lists.ozlabs.org
> Cc: linux-s390@vger.kernel.org
> Cc: linux-sh@vger.kernel.org
> Cc: sparclinux@vger.kernel.org
> ---
>  Changes in v5:
>   - Fix kprobe_ftrace_handler in arch/powerpc too.
> ---
>  arch/arc/kernel/kprobes.c            |    5 +++--
>  arch/arm/probes/kprobes/core.c       |   10 +++++-----
>  arch/arm64/kernel/probes/kprobes.c   |   10 +++++-----
>  arch/ia64/kernel/kprobes.c           |   13 ++++---------
>  arch/mips/kernel/kprobes.c           |    4 ++--
>  arch/powerpc/kernel/kprobes-ftrace.c |   15 ++++++---------
>  arch/powerpc/kernel/kprobes.c        |    7 +++++--

For the powerpc bits:
Acked-by: Naveen N. Rao <naveen.n.rao@linux.vnet.ibm.com>

Thanks,
Naveen


