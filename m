From: Sam Ravnborg <sam@ravnborg.org>
Date: Fri, 09 Jan 2009 19:28:41 +0000
Subject: Re: [PATCH 1/6]Make recordmcount destinct module compile
Message-Id: <20090109192841.GA19482@uranus.ravnborg.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1231468368.10683.100.camel@sli10-desk.sh.intel.com> <alpine.DEB.1.10.0901082142510.18713@gandalf.stny.rr.com>
In-Reply-To: <alpine.DEB.1.10.0901082142510.18713@gandalf.stny.rr.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Shaohua Li <shaohua.li@intel.com>, ia64 <linux-ia64@vger.kernel.org>, "Luck, Tony" <tony.luck@intel.com>, Ingo Molnar <mingo@elte.hu>, linux-kbuild@vger.kernel.org

On Thu, Jan 08, 2009 at 09:45:14PM -0500, Steven Rostedt wrote:
> 
> [ Added Sam and linux-kbuild to the CC list ]
> 
> Since this patch touches not just recordmcount.pl but also the kbuild 
> system, I want the maintainers to be aware.
> 
> Sam, this patch look OK with you, and if it does, can you ack it.
> 
> Thanks,
> 
> -- Steve
> 
> 
> On Fri, 9 Jan 2009, Shaohua Li wrote:
> 
> > In IA64, module build and kernel build use different option.
> > Make recordmcount.pl differentiate the two cases.
> > 
> > Signed-off-by: Shaohua Li <shaohua.li@intel.com>
> > ---
> >  scripts/Makefile.build  |    9 ++++++++-
> >  scripts/recordmcount.pl |    6 +++---
> >  2 files changed, 11 insertions(+), 4 deletions(-)
> > 
> > Index: linux/scripts/Makefile.build
> > =================================> > --- linux.orig/scripts/Makefile.build	2009-01-09 09:52:01.000000000 +0800
> > +++ linux/scripts/Makefile.build	2009-01-09 09:52:36.000000000 +0800
> > @@ -114,6 +114,7 @@ endif
> >  # Default is built-in, unless we know otherwise
> >  modkern_cflags := $(CFLAGS_KERNEL)
> >  quiet_modtag := $(empty)   $(empty)
> > +is_module := 0
> >  
> >  $(real-objs-m)        : modkern_cflags := $(CFLAGS_MODULE)
> >  $(real-objs-m:.o=.i)  : modkern_cflags := $(CFLAGS_MODULE)
> > @@ -125,6 +126,11 @@ $(real-objs-m:.o=.i)  : quiet_modtag := 
> >  $(real-objs-m:.o=.s)  : quiet_modtag := [M]
> >  $(real-objs-m:.o=.lst): quiet_modtag := [M]
> >  
> > +$(real-objs-m)        : is_module := 1
> > +$(real-objs-m:.o=.i)  : is_module := 1
> > +$(real-objs-m:.o=.s)  : is_module := 1
> > +$(real-objs-m:.o=.lst): is_module := 1
> > +

So we duplicate the cases where we identify "this .o file
is used in a module".
This is not good.

Also there is no reason to do this for the .i, .s and .lst
targets as they do not invode recordmcount.pl anyway.

If your build your patch on top of the following we avoid
the duplicated list.

	Sam

diff --git a/scripts/Makefile.build b/scripts/Makefile.build
index 5d90030..3a23239 100644
--- a/scripts/Makefile.build
+++ b/scripts/Makefile.build
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
