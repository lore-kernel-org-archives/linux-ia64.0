From: Jesse Barnes <jbarnes@sgi.com>
Date: Thu, 06 Mar 2003 22:53:21 +0000
Subject: Re: [Linux-ia64] SN makefile stuff
Message-Id: <marc-linux-ia64-105590709805992@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Mar 06, 2003 at 10:39:36PM +0100, Sam Ravnborg wrote:
> On Wed, Mar 05, 2003 at 04:12:49PM -0800, Jesse Barnes wrote:
> 
> Hi Jesse.
> >From a Makefile perspective it looks like you have made a really good job.
> A few comments - see below.

Thanks for looking at this, I hadn't yet dug out your last mail about
what I should be doing, so I wasn't sure if I remembered everything.

> Usually I use the rule to convert to full path in arch/$(ARCH)/Makefile
> 
> The following is preferred assuming you generate file named fakeprom.
> > +	$(Q)$(MAKE) $(build)=$(fakeprom) $(fakeprom)/$@

Oh, ok.

> > diff -Naru linux-2.5.60-ia64-sn/arch/ia64/sn/fakeprom/Makefile work-sn2/arch/ia64/sn/fakeprom/Makefile
> > --- linux-2.5.60-ia64-sn/arch/ia64/sn/fakeprom/Makefile	Mon Feb 10 10:38:53 2003
> > +++ work-sn2/arch/ia64/sn/fakeprom/Makefile	Mon Mar  3 13:30:10 2003
> >  
> > -obj-y=fpromasm.o main.o fw-emu.o fpmem.o klgraph_init.o
> > +targets-$(CONFIG_IA64_SGI_SN) := fakeprom
> Cannot (from the patch) see the purpose of this assignment.

I didn't know about EXTRA_TARGETS, but I think this allowed it to
build when I called 'make fakeprom'.

> > -fprom: $(OBJ)
> > -	$(LD) -static -Tfprom.lds -o fprom $(OBJ) $(LIB)
> > +OBJS := $(obj)/fpromasm.o $(obj)/main.o $(obj)/fw-emu.o $(obj)/fpmem.o \
> > +	$(obj)/klgraph_init.o
> >  
> > -.S.o:
> > -	$(CC)  -D__ASSEMBLY__ $(AFLAGS) $(AFLAGS_KERNEL) -c -o $*.o $<
> > -.c.o:
> > -	$(CC)  $(CFLAGS) $(CFLAGS_KERNEL) -c -o $*.o $<
> > +fakeprom: $(obj)/fakeprom $(obj)/vmlinux.sym
> > +	cp $(obj)/fakeprom $(obj)/fprom
> $(obj)/fprom is a target here.

I should probably just generate fprom directly instead of copying it,
otherwise I should use $(src)/fprom?

> > +
> > +$(obj)/fakeprom: $(src)/fprom.lds $(OBJS) arch/ia64/lib/lib.a
> > +	$(call if_changed,ld)
>
> You must add FORCE as prerequisite, otherwise it will not work as expected.
> All targets used must be listed in: EXTRA_TARGETS
> EXTRA_TARGETS := fprom fakeprom vmlinux.sym

Could that explain why the files in arch/ia64/sn/fakeprom get rebuilt
everytime?

I'll fix this stuff up and post a diff against David's next patch (or
bk tree, hint hint :).

Thanks,
Jesse

