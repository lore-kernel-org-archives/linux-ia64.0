From: Valentin Schneider <valentin.schneider@arm.com>
Date: Tue, 12 Mar 2019 18:18:55 +0000
Subject: Re: [PATCH 00/14] entry: preempt_schedule_irq() callers scrub
Message-Id: <a5b1605b-b3b3-7898-30ae-d993050e8c7a@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190311224752.8337-1-valentin.schneider@arm.com>
 <e604601e-f8e1-a8b5-d364-69ca967996ce@synopsys.com>
In-Reply-To: <e604601e-f8e1-a8b5-d364-69ca967996ce@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Vineet Gupta <vineet.gupta1@synopsys.com>, linux-kernel@vger.kernel.org
Cc: Julien Thierry <julien.thierry@arm.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, linux-xtensa@linux-xtensa.org, x86@kernel.org, sparclinux@vger.kernel.org, linux-sh@vger.kernel.org, linux-riscv@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, linux-mips@vger.kernel.org, uclinux-h8-devel@lists.sourceforge.jp, linux-c6x-dev@linux-c6x.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-m68k@lists.linux-m68k.org, nios2-dev@lists.rocketboards.org

On 12/03/2019 18:03, Vineet Gupta wrote:
[...]
>> Regarding that loop, archs seem to fall in 3 categories:
>> A) Those that don't have the loop
> 
> Please clarify that this is the right thing to do (since core code already has the
> loop) hence no fixing is required for this "category"
> 

Right, those don't need any change. I had a brief look at them to double
check they had the proper need_resched() gate before calling
preempt_schedule_irq() (with no loop) and they all seem fine. Also...

>> B) Those that have a small need_resched() loop around the
>>    preempt_schedule_irq() callsite
>> C) Those that branch to some more generic code further up the entry code
>>    and eventually branch back to preempt_schedule_irq()
>>
>> arc, m68k, nios2 fall in A)
> 

I forgot to include parisc in here.

[...]
