From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 08 Oct 2003 15:55:44 +0000
Subject: Re: Why does salinfo_log_read_cpu use kmalloc?
Message-Id: <marc-linux-ia64-106562884909569@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106559698807998@msgid-missing>
In-Reply-To: <marc-linux-ia64-106559698807998@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday 08 October 2003 1:08 am, Keith Owens wrote:
> Why does arch/ia64/kernel/salinfo.c::salinfo_log_read_cpu() use
> kmalloc() for the log buffer?  The code is running virtual with
> interrupts enabled, SAL_GET_STATE_INFO has no special requirements for
> the buffer attributes, so why not use vmalloc()?

It's usually called via smp_call_function_single(), which uses
an IPI to make it happen on another processor.  I thought
this meant the function got called with interrupts disabled,
but I could be wrong.

And yes, I do need to push this to 2.6.  It's on my to-do list.

Bjorn

