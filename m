From: Takao Indoh <indou.takao@jp.fujitsu.com>
Date: Wed, 06 Sep 2006 09:06:53 +0000
Subject: Re: [PATCH]IA64 kexec/kdump patch for INIT
Message-Id: <80C6D193CBABB1indou.takao@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <75C6D0E56B35AEindou.takao@jp.fujitsu.com>
In-Reply-To: <75C6D0E56B35AEindou.takao@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

Thanks for comments.
I'll reflect your comments and release new patch.

On Wed, 06 Sep 2006 16:47:51 +1200, Keith Owens wrote:

>>Current kdump uses simple IPI to stop cpus, so cpu does not stop
>>if the cpu disables interruption. INIT interruption is non-maskable and
>>it can stop cpus surely.
>
>You will get better results if you send a normal IPI first, wait a bit,
>then send a non-maskable INIT to just those cpus that have not
>responded.  Why?  Because INIT can catch the target cpu in any state,
>including down in prom in physical mode or in the assembler code that
>is busy saving the registers.  At that point you can forget about
>getting any useful backtrace on that cpu.  Sending a normal IPI first
>gives the target cpu a chance to get out of any critical section which
>gives you a much better backtrace.
>
>KDB has been using the dual interrupt method since March 2006 and it
>has significantly improved the diagnostics.  I am happy to work on
>common code that can be used by both kdump and kdb to handle stuck cpus
>and still get a reasonable backtrace.

I agree. I'm also happy if kdb and kdump share the code.
I'll check kdb code.


>>+		/* change region of gp to region5 */
>>+		asm volatile ("movl gp=__gp"::: "memory");
>
>Why?  gp is already pointing at the kernel code before we enter
>ia64_init_handler().

The purpose of this code is just changing region of gp from region7 to 
region5. For example, if gp is e000000004ace170, I want to change gp to
a000000104ace170, but I couldn't find good method. Is there good method
to change region?

Regards,
Takao Indoh

