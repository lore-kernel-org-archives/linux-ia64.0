From: Bill Nottingham <notting@redhat.com>
Date: Tue, 26 Jun 2001 16:24:20 +0000
Subject: [Linux-ia64] Re: volatile unsigned long cpu_online_map vs unsigned long cpu_online_map
Message-Id: <marc-linux-ia64-105590693005772@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger (davidm@hpl.hp.com) said: 
>   Andreas> include/asm-ia64/smp.h has 'extern unsigned long
>   Andreas> cpu_online_map', but arch/ia64/kernel/setup.c and
>   Andreas> arch/ia64/kernel/smpboot.c have 'volatile unsigned long
>   Andreas> cpu_online_map'.  Which one is correct?
> 
> It should be volatile.

Also, shoudn't it be extern in at least one of setup.c/smpboot.c?

Bill

