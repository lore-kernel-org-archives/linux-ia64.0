From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Date: Tue, 06 Jan 2015 18:28:18 +0000
Subject: Re: [PATCH] arch: ia64: kernel: irq_ia64.c: Remove unused function
Message-Id: <CAKXHbyMxv_wEH8ZT5jymiipiYS_Y52cDRJ8QS97tr3VAk6LPaQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1419095222-9942-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
	<CA+8MBbKKp7+mAk49G=Qsnm7tZC_6YUqPN9yeo8BE_X9YRSSbRQ@mail.gmail.com>
In-Reply-To: <CA+8MBbKKp7+mAk49G=Qsnm7tZC_6YUqPN9yeo8BE_X9YRSSbRQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@gmail.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Grant Likely <grant.likely@linaro.org>, Christoph Lameter <cl@linux.com>, Tejun Heo <tj@kernel.org>, Michael Opdenacker <michael.opdenacker@free-electrons.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

2015-01-05 20:33 GMT+01:00 Tony Luck <tony.luck@gmail.com>:
> On Sat, Dec 20, 2014 at 9:07 AM, Rickard Strandqvist
> <rickard_strandqvist@spectrumdigital.se> wrote:
>> Remove the function ia64_handle_irq() that is not used anywhere.
>>
>> This was partially found by using a static code analysis program called cppcheck.
>
> $ git grep ia64_handle_irq
> arch/ia64/kernel/irq_ia64.c:ia64_handle_irq (ia64_vector vector,
> struct pt_regs *regs)
> arch/ia64/kernel/irq_ia64.c:
> printk("ia64_handle_irq: DANGER: less than "
> arch/ia64/kernel/irq_ia64.c:                     * Now try calling
> normal ia64_handle_irq as it would have got called
> arch/ia64/kernel/ivt.S: br.call.sptk.many b6=ia64_handle_irq
>
> Note that last line. ia64_handle_irq() is called from assembly code
>
> -Tony


Hi Tony

Excuse me, this was a totally unnecessary patch :(
I have otherwise tried to pay attention to just that.

Kind regards
Rickard Strandqvist
