From: Steven Rostedt <srostedt@redhat.com>
Date: Thu, 25 Dec 2008 03:54:33 +0000
Subject: Re: [PATCH 5/5] IA64 dynamic ftrace support
Message-Id: <1230177273.30177.134.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <1230012500.10933.102.camel@sli10-desk.sh.intel.com>
In-Reply-To: <1230012500.10933.102.camel@sli10-desk.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Thu, 2008-12-25 at 09:08 +0800, Shaohua Li wrote:
> On Thu, Dec 25, 2008 at 05:50:50AM +0800, Keith Owens wrote:
> > On Wed, 24 Dec 2008 08:29:05 -0500, 
> > Steven Rostedt <srostedt@redhat.com> wrote:
> > >Yes I understand that the module and kernel code is set up differently,
> > >PPC is pretty much the same in this aspect. I'm asking if it is easy to
> > >change a call from the module to kernel core to another function in
> > >kernel core?
> > >
> > >Question: if I have a call from the module to _mcount, how much has to
> > >change in the set up of the registers to make it call ftrace_call
> > >instead?  Perhaps we could link in a call to ftrace_call via the tricks
> > >in recordmcount.pl to get the info needed to make that change?
> > 
> > The IA64 kernel uses the same gp register throughout, it is compiled
> > with -mconstant-gp.  So changing the target address from one kernel
> > function to another only requires changing the destination address in
> > the PLT stub, no other registers are affected.
> yes, for kernel, this is simple. Just changing the target address is ok,
> and the change is atomic, as it's a 64-bit write. For module, it's not
> simple. Module has different gp register against kernel. In a module,
> _mcount must save its gp first and then jump to kernel. That's why we
> can't directly use a jump.
> 
> I'm considering link some code to ftrace_call in recordmcount.pl, but
> recordmocunt.pl is called for each file. If a module has multiple files,
> there will be some duplicate code. Another issue how can we find the
> code's address when ftrace to convert code to nop.

Since this still sounds like PPC actions, I'll try to show a pseudo code
style example.

I'm assuming that a call to mcount from a module looks something like
this:

	save module gp
	load kernel gp
	jump to mcount (or to a mcount trampoline)

Since mcount and ftrace_caller share the same gp, could we not just
change that jmp to ftrace_caller instead? (or to a trampoline to
ftrace_caller as we do in PPC).

-- Steve


