From: Don Dugger <n0ano@valinux.com>
Date: Fri, 15 Dec 2000 17:07:52 +0000
Subject: Re: [Linux-ia64] test11, test12 kernel vs. big sur: Unexpected irq vector
Message-Id: <marc-linux-ia64-105590678205851@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205850@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205850@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

John-

Two questions:

1)  What version of the firmware are you running?

2)  Are you including ACPI support?  I found that most IRQ problems
go away when you do this.
  
On Fri, Dec 15, 2000 at 11:32:48AM -0500, John Kohl wrote:
> I tried booting a kernel built from the latest test12 patch kit on one
> of our development systems (big sur, A stepping).  It
> starts up, prints out a few messages, then loops forever printing
>        Unexpected irq vector 0x0 on CPU 0!
> This comes from arch/ia64/kernel/irq.c.
> 
> We had the same problems with the test11 kernels.  Any suggestions on
> how to debug and/or remedy this?
> 
> -- 
> =John Kohl <jtk@rational.com>, Software Engineer
> Rational Software, Configuration Management Business Unit
> Mark your calendars!  Rational User Conference 2001, July 22-26, 2001
> in beautiful Denver, Colorado
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

-- 
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@valinux.com
Ph: 303/938-9838

