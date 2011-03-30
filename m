From: Thomas Gleixner <tglx@linutronix.de>
Date: Wed, 30 Mar 2011 09:51:44 +0000
Subject: Re: [patch 12/23] ia64: sn: Drop unused function
Message-Id: <alpine.LFD.2.00.1103301149220.22418@localhost6.localdomain6>
List-Id: <linux-ia64.vger.kernel.org>
References: <20110325204515.641974350@linutronix.de>
In-Reply-To: <20110325204515.641974350@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 29 Mar 2011, Tony Luck wrote:

> On Fri, Mar 25, 2011 at 1:51 PM, Thomas Gleixner <tglx@linutronix.de> wrote:
> > Leftover from the irq chip conversion.
> ...
> > -int sn_force_interrupt_flag = 1;
> 
> This seems to be still used ... 2.6.39-rc1 fails to build with:
> 
> arch/ia64/sn/built-in.o: In function 'sn_force_interrupt_show':
> sn_proc_fs.c:(.text+0xdc21): undefined reference to 'sn_force_interrupt_flag'

Hmpf. Missed that as well. So probably that code in sn_proc_fs should
be fixed as well, right ?

Thanks,

	tglx


