From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Thu, 22 May 2003 21:29:34 +0000
Subject: Re: [Linux-ia64] SAL error record logging/decoding
Message-Id: <marc-linux-ia64-105590723705987@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705660@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705660@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday 21 May 2003 2:48 pm, Luck, Tony wrote:
> The #ifdef CONFIG_SMP in the read/write functions seems a little
> convoluted, resulting in the weird can't ever happen error message
> for the non-SMP case that is trying to read/write from the wrong
> cpu.  Why not write each in the form:
> 
> #ifdef CONFIG_SMP
>         if (cpu = smp_processor_id())
>                 salinfo_log_read_cpu(&info);
>         else
>                 smp_call_function_single(cpu, salinfo_log_read_cpu, &info, 0, 1);
> #else
>         salinfo_log_read_cpu(&info);
> #endif

Nice!  I copied the original from somewhere (can't
remember where ATM), but yours is much better.  Thanks!

Bjorn

