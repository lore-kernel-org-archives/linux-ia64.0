From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 25 Jun 2004 00:36:58 +0000
Subject: RE: BUG 2.6.7 hangs on boot (rx2600)
Message-Id: <200406250035.i5P0ZWY23430@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040622061505.GA23075@cup.hp.com>
In-Reply-To: <20040622061505.GA23075@cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>> Bjorn Helgaas wrote on Wednesday, June 23, 2004 3:51 PM
> On Wednesday 23 June 2004 8:26 am, Tian, Kevin wrote:
> > I'm suspecting line in ia64_switch_to:
> > 	/*
> > 	* If we've already mapped this task's page, we can skip doing it
> > again.
> > 	*/
> > (p6)	cmp.eq p7,p6=r27,r27 <----- Should here cmp.eq.unc be used
> > instead? No time to test it now...
>
> Your change evidently solves the problem, but I don't understand
> how.  Can you enlighten me?  Here's the essence of the code:
>


This is called black magic and pure coincidence. Welcome to the world
of randomness.  If I boot that "unc" Kernel frequent enough, it will
hang eventually.  Without "unc" it also has 30/70 fail/pass rate.

The regression is coming from moving init_task from region 7 to region
5.  The hang was a nested fault with no valid dtlb mapping for the init
task's stack.  The problem was from physical mode efi call.  efi_call_phys
does: ia64_switch_mode_phys, call the function, then ia64_switch_mode_virt.
The ia64_switch_mode_virt now need to special case the init task to put
sp and ar.bspstore into region5 instead of region7.  I have a quick patch
that fix the hang.  Let me polish it a bit more and then post.

Oh yeah, baby, the first two hunk in head.S is just plain wrong in this
patch: http://www.gelato.unsw.edu.au/linux-ia64/0406/10047.html.  Let me
work on that too .....

- Ken


