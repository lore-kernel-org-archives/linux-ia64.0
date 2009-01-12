From: Shaohua Li <shaohua.li@intel.com>
Date: Mon, 12 Jan 2009 02:00:51 +0000
Subject: Re: [PATCH 1/6]Make recordmcount destinct module compile
Message-Id: <1231725651.5130.2.camel@sli10-desk.sh.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1231468368.10683.100.camel@sli10-desk.sh.intel.com>
	 <alpine.DEB.1.10.0901082142510.18713@gandalf.stny.rr.com>
	 <20090109192841.GA19482@uranus.ravnborg.org>
	 <alpine.DEB.1.10.0901091456390.17378@gandalf.stny.rr.com>
	 <20090109200514.GA24634@uranus.ravnborg.org>
In-Reply-To: <20090109200514.GA24634@uranus.ravnborg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sam Ravnborg <sam@ravnborg.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, ia64 <linux-ia64@vger.kernel.org>, "Luck, Tony" <tony.luck@intel.com>, Ingo Molnar <mingo@elte.hu>, "linux-kbuild@vger.kernel.org" <linux-kbuild@vger.kernel.org>

On Sat, 2009-01-10 at 04:05 +0800, Sam Ravnborg wrote:
> On Fri, Jan 09, 2009 at 02:57:38PM -0500, Steven Rostedt wrote:
> > 
> > On Fri, 9 Jan 2009, Sam Ravnborg wrote:
> > > So we duplicate the cases where we identify "this .o file
> > > is used in a module".
> > > This is not good.
> > > 
> > > Also there is no reason to do this for the .i, .s and .lst
> > > targets as they do not invode recordmcount.pl anyway.
> > > 
> > > If your build your patch on top of the following we avoid
> > > the duplicated list.
> > > 
> > > 	Sam
> > 
> > Thanks Sam,
> > 
> > Can I add this on top of Shaohua's and put your Signed-off-by, as well
> > as an Acked-by on Shaohua's?
> 
> My patch was made on top of -linus so you
> need to use the flag in the call to recordmount.pl.
> 
> Please feel free to put my Acked-by: on the patch,
> but as this does not originate from me it would be the
> wrong documentation trail to add my Sigend-off-by
> as I just gave an improvement proposal.
Ok, refreshed. Other patches don't need changes.

In IA64, module build and kernel build use different option.
Make recordmcount.pl differentiate the two cases.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>
Acked-by: Sam Ravnborg <sam@ravnborg.org>
---
 scripts/Makefile.build  |   13 +++++++------
 scripts/recordmcount.pl |    6 +++---
 2 files changed, 10 insertions(+), 9 deletions(-)

Index: linux/scripts/Makefile.build
=================================--- linux.orig/scripts/Makefile.build	2009-01-09 10:51:05.000000000 +0800
+++ linux/scripts/Makefile.build	2009-01-12 09:39:25.000000000 +0800
@@ -112,13 +112,13 @@ endif
 # ---------------------------------------------------------------------------
 
 # Default is built-in, unless we know otherwise
-modkern_cflags := $(CFLAGS_KERNEL)
+modkern_cflags = $(if $(part-of-module), $(CFLAGS_MODULE), $(CFLAGS_KERNEL))
 quiet_modtag := $(empty)   $(empty)
 
-$(real-objs-m)        : modkern_cflags := $(CFLAGS_MODULE)
-$(real-objs-m:.o=.i)  : modkern_cflags := $(CFLAGS_MODULE)
-$(real-objs-m:.o=.s)  : modkern_cflags := $(CFLAGS_MODULE)
-$(real-objs-m:.o=.lst): modkern_cflags := $(CFLAGS_MODULE)
+$(real-objs-m)        : part-of-module := y
+$(real-objs-m:.o=.i)  : part-of-module := y
+$(real-objs-m:.o=.s)  : part-of-module := y
+$(real-objs-m:.o=.lst): part-of-module := y
 
 $(real-objs-m)        : quiet_modtag := [M]
 $(real-objs-m:.o=.i)  : quiet_modtag := [M]
@@ -215,7 +215,8 @@ endif
 ifdef CONFIG_FTRACE_MCOUNT_RECORD
 cmd_record_mcount = perl $(srctree)/scripts/recordmcount.pl "$(ARCH)" \
 	"$(if $(CONFIG_64BIT),64,32)" \
-	"$(OBJDUMP)" "$(OBJCOPY)" "$(CC)" "$(LD)" "$(NM)" "$(RM)" "$(MV)" "$(@)";
+	"$(OBJDUMP)" "$(OBJCOPY)" "$(CC)" "$(LD)" "$(NM)" "$(RM)" "$(MV)" \
+	"$(if $(part-of-module),1,0)" "$(@)";
 endif
 
 define rule_cc_o_c
Index: linux/scripts/recordmcount.pl
=================================--- linux.orig/scripts/recordmcount.pl	2009-01-09 10:45:05.000000000 +0800
+++ linux/scripts/recordmcount.pl	2009-01-12 09:48:46.000000000 +0800
@@ -100,14 +100,14 @@ $P =~ s@.*/@@g;
 
 my $V = '0.1';
 
-if ($#ARGV < 6) {
-	print "usage: $P arch objdump objcopy cc ld nm rm mv inputfile\n";
+if ($#ARGV < 7) {
+	print "usage: $P arch objdump objcopy cc ld nm rm mv is_module inputfile\n";
 	print "version: $V\n";
 	exit(1);
 }
 
 my ($arch, $bits, $objdump, $objcopy, $cc,
-    $ld, $nm, $rm, $mv, $inputfile) = @ARGV;
+    $ld, $nm, $rm, $mv, $is_module, $inputfile) = @ARGV;
 
 # Acceptable sections to record.
 my %text_sections = (


