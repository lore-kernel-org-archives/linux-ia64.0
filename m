From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 11 Mar 2005 19:12:12 +0000
Subject: RE: [RFC] Enhanced show_stack output to add backing store regs
Message-Id: <200503111912.j2BJCBg14861@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1110566404.498.79.camel@localhost.localdomain>
In-Reply-To: <1110566404.498.79.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Bob Montgomery wrote on Friday, March 11, 2005 10:40 AM
>
> I have a patch for arch/ia64/kernel/process.c that changes
> ia64_do_show_stack to show the contents of the register backing store
> for each level.  I think this will help our post-mortem debugging
> of hard-to-reproduce problems, especially when customers do not have
> a working kernel core dump facility, by allowing us to see function
> argument registers and some of the locals for each function leading
> to the oops.  Note: this doesn't capture function arguments per se,
> since the argument register(s) could have been modified prior to the
> call to the next stack level.  You still have to read disassembly to
> debug this way :-)
>
> Is this generally interesting?  I'm wondering if it isn't currently
> done because of some issue with oops message size, or excessive
> printk's causing problems elsewhere?

Very nice and I think is extremely valuable for debugging, especially
the stack register dump.  I vote YES!!

- Ken


