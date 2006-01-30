From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Mon, 30 Jan 2006 19:26:04 +0000
Subject: RE: boot-time slowdown for measure_migration_cost
Message-Id: <200601301926.k0UJQBg16647@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <20060130172140.GB11793@elte.hu>
References: <200601271403.27065.bjorn.helgaas@hp.com>
In-Reply-To: <200601271403.27065.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Ingo Molnar' <mingo@elte.hu>, Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: Ingo Molnar <mingo@redhat.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Ingo Molnar wrote on Monday, January 30, 2006 9:22 AM
> - in kernel/sched.c, decrease ITERATIONS from 2 to 1. This will make the 
>   measurement more noisy though.
> 
> - in kernel/sched.c, change this line:
> 
>                 size = size * 20 / 19;
> 
>   to:
> 
>                 size = size * 10 / 9;
> 
>   this will probably halve the cost - against at the expense of 
>   accuracy and statistical stability.

I think the kernel should keep the accuracy and stability.  One option
would be by default not to measure the migration cost.  For people who
wants to have an accurate scheduler parameter, they can turn on a boot
time option to do the measure.

- Ken

