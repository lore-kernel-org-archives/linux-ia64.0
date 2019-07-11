From: Anshuman Khandual <anshuman.khandual@arm.com>
Date: Thu, 11 Jul 2019 09:58:11 +0000
Subject: Re: [PATCH] mm/kprobes: Add generic kprobe_fault_handler() fallback definition
Message-Id: <542893ae-ed64-55b2-11ee-1f19710a25e4@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1562304629-29376-1-git-send-email-anshuman.khandual@arm.com>
In-Reply-To: <1562304629-29376-1-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Kate Stewart <kstewart@linuxfoundation.org>, Mark Rutland <mark.rutland@arm.com>, Rich Felker <dalias@libc.org>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mips@vger.kernel.org, Richard Fontana <rfontana@redhat.com>, Paul Mackerras <paulus@samba.org>, "H. Peter Anvin" <hpa@zytor.com>, sparclinux@vger.kernel.org, Will Deacon <will@kernel.org>, linux-s390@vger.kernel.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, Russell King <linux@armlinux.org.uk>, Anil S Keshavamurthy <anil.s.keshavamurthy@intel.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Ingo Molnar <mingo@redhat.com>, linux-arm-kernel@lists.infradead.org, Catalin Marinas <catalin.marinas@arm.com>, James Hogan <jhogan@kernel.org>, linux-snps-arc@lists.infradead.org, Guenter Roeck <linux@roeck-us.net>, Fenghua Yu <fenghua.yu@intel.com>, Vasily Gorbik <gor@linux.ibm.com>, linuxppc-dev@lists.ozlabs.org, "Naveen N. Rao" <naveen.n.rao@linux.ibm.com>, Borislav Petkov <bp@alien8.de>, Thomas Gleixner <tglx@linutronix.de>, Allison Randal <allison@lohutok.net>, Tony Luck <tony.luck@intel.com>, Vineet Gupta <vgupta@synopsys.com>, linux-kernel@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, Paul Burton <paul.burton@mips.com>, Masami Hiramatsu <mhiramat@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Enrico Weigelt <info@metux.net>, "David S. Miller" <davem@davemloft.net>



On 07/05/2019 11:00 AM, Anshuman Khandual wrote:
> Architectures like parisc enable CONFIG_KROBES without having a definition
> for kprobe_fault_handler() which results in a build failure. Arch needs to
> provide kprobe_fault_handler() as it is platform specific and cannot have
> a generic working alternative. But in the event when platform lacks such a
> definition there needs to be a fallback.
> 
> This adds a stub kprobe_fault_handler() definition which not only prevents
> a build failure but also makes sure that kprobe_page_fault() if called will
> always return negative in absence of a sane platform specific alternative.
> 
> While here wrap kprobe_page_fault() in CONFIG_KPROBES. This enables stud
> definitions for generic kporbe_fault_handler() and kprobes_built_in() can
> just be dropped. Only on x86 it needs to be added back locally as it gets
> used in a !CONFIG_KPROBES function do_general_protection().
> 
> Cc: Vineet Gupta <vgupta@synopsys.com>
> Cc: Russell King <linux@armlinux.org.uk>
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Will Deacon <will@kernel.org>
> Cc: Tony Luck <tony.luck@intel.com>
> Cc: Fenghua Yu <fenghua.yu@intel.com>
> Cc: Ralf Baechle <ralf@linux-mips.org>
> Cc: Paul Burton <paul.burton@mips.com>
> Cc: James Hogan <jhogan@kernel.org>
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: Paul Mackerras <paulus@samba.org>
> Cc: Michael Ellerman <mpe@ellerman.id.au>
> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> Cc: Vasily Gorbik <gor@linux.ibm.com>
> Cc: Christian Borntraeger <borntraeger@de.ibm.com>
> Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
> Cc: Rich Felker <dalias@libc.org>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: Borislav Petkov <bp@alien8.de>
> Cc: "H. Peter Anvin" <hpa@zytor.com>
> Cc: "Naveen N. Rao" <naveen.n.rao@linux.ibm.com>
> Cc: Anil S Keshavamurthy <anil.s.keshavamurthy@intel.com>
> Cc: Masami Hiramatsu <mhiramat@kernel.org>
> Cc: Allison Randal <allison@lohutok.net>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: Enrico Weigelt <info@metux.net>
> Cc: Richard Fontana <rfontana@redhat.com>
> Cc: Kate Stewart <kstewart@linuxfoundation.org>
> Cc: Mark Rutland <mark.rutland@arm.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Guenter Roeck <linux@roeck-us.net>
> Cc: x86@kernel.org
> Cc: linux-snps-arc@lists.infradead.org
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-arm-kernel@lists.infradead.org
> Cc: linux-ia64@vger.kernel.org
> Cc: linux-mips@vger.kernel.org
> Cc: linuxppc-dev@lists.ozlabs.org
> Cc: linux-s390@vger.kernel.org
> Cc: linux-sh@vger.kernel.org
> Cc: sparclinux@vger.kernel.org
> 
> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
> ---

Any updates or suggestions on this patch ? Currently there is a build failure on
parisc architecture due to the lack of a kprobe_fault_handler() definition when
CONFIG_KPROBES is enabled and this build failure needs to be fixed.

This patch solves the build problem. But otherwise I am also happy to just define
a stub definition for kprobe_fault_handler() on parisc arch when CONFIG_KPROBES
is enabled, which will avoid the build failure. Please suggest.
