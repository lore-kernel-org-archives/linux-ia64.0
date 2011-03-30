From: Tony Luck <tony.luck@intel.com>
Date: Wed, 30 Mar 2011 00:09:34 +0000
Subject: Re: [patch 12/23] ia64: sn: Drop unused function
Message-Id: <AANLkTikOxe6fOfTEWJPJjJc0bktfG=knBBssqg-+4xjy@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20110325204515.641974350@linutronix.de>
In-Reply-To: <20110325204515.641974350@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Mar 25, 2011 at 1:51 PM, Thomas Gleixner <tglx@linutronix.de> wrote:
> Leftover from the irq chip conversion.
...
> -int sn_force_interrupt_flag = 1;

This seems to be still used ... 2.6.39-rc1 fails to build with:

arch/ia64/sn/built-in.o: In function 'sn_force_interrupt_show':
sn_proc_fs.c:(.text+0xdc21): undefined reference to 'sn_force_interrupt_flag'

-Tony

[Sorry I didn't find this before it went upstream]
