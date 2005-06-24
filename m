From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 24 Jun 2005 01:38:33 +0000
Subject: Re: [patch][ia64]Refuse kprobe on ivt code
Message-Id: <17083.25625.991516.736507@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050623172832.B26121@unix-os.sc.intel.com>
In-Reply-To: <20050623172832.B26121@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Keshavamurthy Anil S <anil.s.keshavamurthy@intel.com>
Cc: akpm@osdl.org, Linux Kernel <linux-kernel@vger.kernel.org>, Linux IA64 <linux-ia64@vger.kernel.org>

Please do the checking based on the .text.ivt section instead (and add
the necessary labels to vmlinux.S and asm-ia64/sections.h).

Thanks,

	--david

>>>>> On Thu, 23 Jun 2005 17:28:33 -0700, Keshavamurthy Anil S <anil.s.keshavamurthy@intel.com> said:

  Anil> Subject: Refuse kprobe insert on IVT code

  Anil> Not safe to insert kprobes on IVT code.

  Anil> This patch checks to see if the address on which Kprobes is
  Anil> being inserted is in ivt code and if it is in ivt code then
  Anil> refuse to register kprobe.

  Anil> Signed-off-by: Anil S Keshavamurthy
  Anil> <anil.s.keshavamurthy@intel.com>

  Anil> =======================  Anil> arch/ia64/kernel/kprobes.c | 13 +++++++++++++ 1 files changed,
  Anil> 13 insertions(+)

  Anil> Index: linux-2.6.12-mm1/arch/ia64/kernel/kprobes.c
  Anil> =================================  Anil> --- linux-2.6.12-mm1.orig/arch/ia64/kernel/kprobes.c +++
  Anil> linux-2.6.12-mm1/arch/ia64/kernel/kprobes.c @@ -263,6 +263,13
  Anil> @@ static inline void get_kprobe_inst(bundl } }
 
  Anil> +/* Returns non-zero if the PC is in the Interrupt Vector
  Anil> Table */ +static inline int in_ivt_code(unsigned long pc) +{ +
  Anil> extern char ia64_ivt[]; + return (pc >= (u_long)ia64_ivt && pc
  Anil> < (u_long)ia64_ivt+32768); +} + static int
  Anil> valid_kprobe_addr(int template, int slot, unsigned long addr)
  Anil> { if ((slot > 2) || ((bundle_encoding[template][1] = L) &&
  Anil> slot > 1)) { @@ -271,6 +278,12 @@ static int
  Anil> valid_kprobe_addr(int templat return -EINVAL; }
 
  Anil> + if (in_ivt_code(addr)) { + printk(KERN_WARNING "Kprobes
  Anil> can't be inserted inside " + "IVT code at 0x%lx\n", addr); +
  Anil> return -EINVAL; + } + if (slot = 1) { printk(KERN_WARNING
  Anil> "Inserting kprobes on slot #1 " "is not supported\n"); - To
  Anil> unsubscribe from this list: send the line "unsubscribe
  Anil> linux-ia64" in the body of a message to
  Anil> majordomo@vger.kernel.org More majordomo info at
  Anil> http://vger.kernel.org/majordomo-info.html
