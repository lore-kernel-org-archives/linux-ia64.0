From: Darren Williams <dsw@gelato.unsw.edu.au>
Date: Fri, 28 May 2004 02:18:51 +0000
Subject: Re: [patch] The actual error #endif up wrt #ifdef __ARCH_WANT_SYS_SIGPROCMASK
Message-Id: <20040528021851.GC4596@cse.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Darren

On Fri, 28 May 2004, Darren Williams wrote:

> 
> Also if
> CONFIG_IA32_SUPPORT
> is not set in the attached config we are getting
> the follwing errors:

arch/ia64/kernel/built-in.o(.rodata+0x4c8): In function `sys_call_table':
: undefined reference to `sys_rt_sigaction'



--------------------------------------------------
Darren Williams <dsw AT gelato.unsw.edu.au>
Gelato@UNSW <www.gelato.unsw.edu.au>
--------------------------------------------------
