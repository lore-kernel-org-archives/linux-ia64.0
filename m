From: Keith Owens <kaos@sgi.com>
Date: Thu, 09 Oct 2003 03:13:50 +0000
Subject: Re: Why does salinfo_log_read_cpu use kmalloc?
Message-Id: <marc-linux-ia64-106566927917419@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106559698807998@msgid-missing>
In-Reply-To: <marc-linux-ia64-106559698807998@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 8 Oct 2003 09:55:44 -0600, 
Bjorn Helgaas <bjorn.helgaas@hp.com> wrote:
>On Wednesday 08 October 2003 1:08 am, Keith Owens wrote:
>> Why does arch/ia64/kernel/salinfo.c::salinfo_log_read_cpu() use
>> kmalloc() for the log buffer?  The code is running virtual with
>> interrupts enabled, SAL_GET_STATE_INFO has no special requirements for
>> the buffer attributes, so why not use vmalloc()?
>
>It's usually called via smp_call_function_single(), which uses
>an IPI to make it happen on another processor.  I thought
>this meant the function got called with interrupts disabled,
>but I could be wrong.

So the question becomes, why use smp_call_function_single() and have
the code run disabled?  salinfo_log_read_cpu() is performing work on
behalf of a user process, we can use set_cpus_allowed() and let the
scheduler run the code on the required cpu with interrupts enabled.

Any objections if I do a patch to replace smp_call_function_single()
with set_cpus_allowed(), so reading the records from SAL does not block
OS interrupts?  For the special case when the task is on the cpu that
salinfo wants to read from, the existing code does not use IPI so it
calls SAL with interrupts enabled.

