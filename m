From: Tony Luck <tony.luck@gmail.com>
Date: Mon, 05 Jan 2015 19:33:28 +0000
Subject: Re: [PATCH] arch: ia64: kernel: irq_ia64.c: Remove unused function
Message-Id: <CA+8MBbKKp7+mAk49G=Qsnm7tZC_6YUqPN9yeo8BE_X9YRSSbRQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1419095222-9942-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
In-Reply-To: <1419095222-9942-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Cc: Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Grant Likely <grant.likely@linaro.org>, Christoph Lameter <cl@linux.com>, Tejun Heo <tj@kernel.org>, Michael Opdenacker <michael.opdenacker@free-electrons.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Sat, Dec 20, 2014 at 9:07 AM, Rickard Strandqvist
<rickard_strandqvist@spectrumdigital.se> wrote:
> Remove the function ia64_handle_irq() that is not used anywhere.
>
> This was partially found by using a static code analysis program called cppcheck.

$ git grep ia64_handle_irq
arch/ia64/kernel/irq_ia64.c:ia64_handle_irq (ia64_vector vector,
struct pt_regs *regs)
arch/ia64/kernel/irq_ia64.c:
printk("ia64_handle_irq: DANGER: less than "
arch/ia64/kernel/irq_ia64.c:                     * Now try calling
normal ia64_handle_irq as it would have got called
arch/ia64/kernel/ivt.S: br.call.sptk.many b6=ia64_handle_irq

Note that last line. ia64_handle_irq() is called from assembly code

-Tony
