From: Steven Rostedt <srostedt@redhat.com>
Date: Wed, 24 Dec 2008 00:48:46 +0000
Subject: Re: [PATCH 3/5]explictly ignore a file in recordmcount.pl
Message-Id: <1230079726.30177.111.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <1230012491.10933.100.camel@sli10-desk.sh.intel.com>
In-Reply-To: <1230012491.10933.100.camel@sli10-desk.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Wed, 2008-12-24 at 08:43 +0800, Shaohua Li wrote:
> On Tue, Dec 23, 2008 at 10:22:04PM +0800, Steven Rostedt wrote:
> > 
> > On Tue, 2008-12-23 at 14:08 +0800, Shaohua Li wrote:
> > > In IA64, a function pointer isn't a 'unsigned long' but a
> > > 'struct {unsigned long ip, unsigned long gp}'. MCOUNT_ADDR is determined
> > > at link time not compile time, so explictly ignore kernel/trace/ftrace.o
> > > in recordmcount.pl.
> > > 
> > > Signed-off-by: Shaohua Li <shaohua.li@intel.com>
> > > ---
> > >  kernel/trace/ftrace.c   |   10 +---------
> > >  scripts/recordmcount.pl |    5 +++++
> > >  2 files changed, 6 insertions(+), 9 deletions(-)
> > > 
> > > Index: linux/kernel/trace/ftrace.c
> > > =================================> > > --- linux.orig/kernel/trace/ftrace.c	2008-12-23 13:11:28.000000000 +0800
> > > +++ linux/kernel/trace/ftrace.c	2008-12-23 13:24:59.000000000 +0800
> > > @@ -263,14 +263,6 @@ static void ftrace_update_pid_func(void)
> > >  # error Dynamic ftrace depends on MCOUNT_RECORD
> > >  #endif
> > >  
> > > -/*
> > > - * Since MCOUNT_ADDR may point to mcount itself, we do not want
> > > - * to get it confused by reading a reference in the code as we
> > > - * are parsing on objcopy output of text. Use a variable for
> > > - * it instead.
> > > - */
> > > -static unsigned long mcount_addr = MCOUNT_ADDR;
> > > -
> > >  enum {
> > >  	FTRACE_ENABLE_CALLS		= (1 << 0),
> > >  	FTRACE_DISABLE_CALLS		= (1 << 1),
> > > @@ -575,7 +567,7 @@ ftrace_code_disable(struct module *mod, 
> > >  
> > >  	ip = rec->ip;
> > >  
> > > -	ret = ftrace_make_nop(mod, rec, mcount_addr);
> > > +	ret = ftrace_make_nop(mod, rec, MCOUNT_ADDR);
> > 
> > This change will make dynamic ftrace fail on other archs (ppc and x86).
> > Please read the comment you deleted. By using MCOUNT_ADDR directly in
> > the code, you will create a reference to mcount in a text section that
> > will confuse recordmcount.pl. It will think this reference is a call to
> > mcount and when it tries to modify it, it will fail because the code is
> > not a call.
> Did you read the changes just at the bottom? I explictly ignored
> kernel/trace/ftrace.o in recordmcount.pl.
> 
> Thanks,
> Shaohua
> 
> > 
> > >  	if (ret) {
> > >  		ftrace_bug(ret, ip);
> > >  		rec->flags |= FTRACE_FL_FAILED;
> > > Index: linux/scripts/recordmcount.pl
> > > =================================> > > --- linux.orig/scripts/recordmcount.pl	2008-12-23 13:24:38.000000000 +0800
> > > +++ linux/scripts/recordmcount.pl	2008-12-23 13:24:59.000000000 +0800
> > > @@ -109,6 +109,11 @@ if ($#ARGV < 7) {
> > >  my ($arch, $bits, $objdump, $objcopy, $cc,
> > >      $ld, $nm, $rm, $mv, $is_module, $inputfile) = @ARGV;
> > >  
> > > +# This file refers to mcount and shouldn't be ftraced, so lets' ignore it
> > > +if ($inputfile eq "kernel/trace/ftrace.o") {
> > > +    exit(0);
> > > +}
> > > +

I did see this before, just forgot about it ;-)

Well, fine then, but it is getting a bit more fragile than I would like.

-- Steve

> > >  # Acceptable sections to record.
> > >  my %text_sections = (
> > >       ".text" => 1,
> > > 
> > > 
> > 

