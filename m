From: Erich Focht <efocht@ess.nec.de>
Date: Wed, 10 Jul 2002 12:34:07 +0000
Subject: [Linux-ia64] Re: O(1) scheduler "complex" macros
Message-Id: <marc-linux-ia64-105590701905756@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905752@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905752@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Ingo,

> there is one more detail - wait_task_inactive() needs to consider the
> ->switch_lock as well - otherwise exit() might end up freeing the
> pagetables earlier than the context-switch has truly finished. The
> udelay(100) test should trigger this race.
>
> i've fixed this and uploaded the -A8 patch:
>
>         http://redhat.com/~mingo/O(1)-scheduler/sched-2.5.25-A8
>
> does this fix the ia64 crashes? you need to define an ia64-specific

looks good! Rock solid despite udelay. Though a bit slower than before...

Thanks a lot for the help!

Erich


