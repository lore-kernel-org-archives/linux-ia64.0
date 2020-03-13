From: afzal mohammed <afzal.mohd.ma@gmail.com>
Date: Fri, 13 Mar 2020 12:43:41 +0000
Subject: Re: [PATCH v4] ia64: replace setup_irq() by request_irq()
Message-Id: <20200313123141.GA7155@afzalpc>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200304004936.4955-1-afzal.mohd.ma@gmail.com>
 <20200308120350.19117-1-afzal.mohd.ma@gmail.com>
In-Reply-To: <20200308120350.19117-1-afzal.mohd.ma@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Hi Tony Luck,

On Sun, Mar 08, 2020 at 05:33:49PM +0530, afzal mohammed wrote:

> request_irq() is preferred over setup_irq(). Invocations of setup_irq()
> occur after memory allocators are ready.
> 
> Per tglx[1], setup_irq() existed in olden days when allocators were not
> ready by the time early interrupts were initialized.
> 
> Hence replace setup_irq() by request_irq().
> 
> Changing 'ia64_native_register_percpu_irq' decleration to include
> 'irq_handler_t' as an argument type in arch/ia64/include/asm/hw_irq.h
> was causing build error - 'unknown type name 'irq_handler_t''
> 
> This was due to below header file sequence,
> + include/interrupt.h
>  + include/hardirq.h
>   + asm/hardirq.h
>    + include/irq.h
>     + asm/hw_irq.h
>        [ 'ia64_native_register_percpu_irq' declared w/ 'irq_handler_t']
>  [ 'irq_handler_t' typedef'ed here in 'include/interrupt.h']
> 
> 'register_percpu_irq' defined to 'ia64_native_register_percpu_irq' is
> the one invoked by the caller, not the latter directly. This was done
> to support paravirtualization which was removed around 4 years back.
> And 'register_percpu_irq' is invoked only inside 'arch/ia64/kernel'.
> 
> So 'register_percpu_irq' define to 'ia64_native_register_percpu_irq' is
> removed, instead 'ia64_native_register_percpu_irq' is renamed to
> 'register_precpu_irq()' & it is directly invoked. Also,
> 'register_precpu_irq()' is declared in a new header file 'irq.h' inside
> 'arch/ia64/kernel/', this header file is included by C files invoking
> 'register_percpu_irq()'.
> 
> [1] https://lkml.kernel.org/r/alpine.DEB.2.20.1710191609480.1971@nanos
> 
> Signed-off-by: afzal mohammed <afzal.mohd.ma@gmail.com>

Seems you handle pull requests for ia64, if this change is okay, can
please consider taking this thr' your tree ?

Regards
afzal
