From: Sam Ravnborg <sam@ravnborg.org>
Date: Fri, 30 Jun 2006 22:43:32 +0000
Subject: Re: ia64 breakage in current -git
Message-Id: <20060630224332.GA29587@mars.ravnborg.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060627010646.21ff5687.akpm@osdl.org>
In-Reply-To: <20060627010646.21ff5687.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Jun 29, 2006 at 12:42:27PM -0600, David Mosberger-Tang wrote:
> The problem seems to come from the use of $(*F) in Makefile.lib:
> 
>  _a_flags       = $(AFLAGS) $(EXTRA_AFLAGS) $(AFLAGS_$(*F).o)
> 
> If I use $(@F) instead of $(*F).o, the build works fine.
Except that we do not always have targets named *.o.

Following is my fix. I have test-compiled a ia64 kernel and checked
the output using some debug statements.

On top of linus- latest.
It would be good if you could try building your kernel with this fix
just to make sure I did not brake anything (it is past midnight here).

	Sam

diff --git a/scripts/Makefile.build b/scripts/Makefile.build
index 53e53a2..e8e7d27 100644
--- a/scripts/Makefile.build
+++ b/scripts/Makefile.build
@@ -117,7 +117,7 @@ quiet_modtag := $(empty)   $(empty)
 $(obj-m)              : quiet_modtag := [M]
 
 # Default for not multi-part modules
-modname = $(*F)
+modname = $(basetarget)
 
 $(multi-objs-m)         : modname = $(modname-multi)
 $(multi-objs-m:.o=.i)   : modname = $(modname-multi)
diff --git a/scripts/Makefile.host b/scripts/Makefile.host
index 2b066d1..18ecd4d 100644
--- a/scripts/Makefile.host
+++ b/scripts/Makefile.host
@@ -80,8 +80,10 @@ obj-dirs += $(host-objdirs)
 #####
 # Handle options to gcc. Support building with separate output directory
 
-_hostc_flags   = $(HOSTCFLAGS)   $(HOST_EXTRACFLAGS)   $(HOSTCFLAGS_$(*F).o)
-_hostcxx_flags = $(HOSTCXXFLAGS) $(HOST_EXTRACXXFLAGS) $(HOSTCXXFLAGS_$(*F).o)
+_hostc_flags   = $(HOSTCFLAGS)   $(HOST_EXTRACFLAGS)   \
+                 $(HOSTCFLAGS_$(basetarget).o)
+_hostcxx_flags = $(HOSTCXXFLAGS) $(HOST_EXTRACXXFLAGS) \
+                 $(HOSTCXXFLAGS_$(basetarget).o)
 
 ifeq ($(KBUILD_SRC),)
 __hostc_flags	= $(_hostc_flags)
diff --git a/scripts/Makefile.lib b/scripts/Makefile.lib
index 2cb4935..fc498fe 100644
--- a/scripts/Makefile.lib
+++ b/scripts/Makefile.lib
@@ -82,12 +82,12 @@ # Note: It's possible that one object ge
 #       than one module. In that case KBUILD_MODNAME will be set to foo_bar,
 #       where foo and bar are the name of the modules.
 name-fix = $(subst $(comma),_,$(subst -,_,$1))
-basename_flags = -D"KBUILD_BASENAME=KBUILD_STR($(call name-fix,$(*F)))"
+basename_flags = -D"KBUILD_BASENAME=KBUILD_STR($(call name-fix,$(basetarget)))"
 modname_flags  = $(if $(filter 1,$(words $(modname))),\
                  -D"KBUILD_MODNAME=KBUILD_STR($(call name-fix,$(modname)))")
 
-_c_flags       = $(CFLAGS) $(EXTRA_CFLAGS) $(CFLAGS_$(*F).o)
-_a_flags       = $(AFLAGS) $(EXTRA_AFLAGS) $(AFLAGS_$(*F).o)
+_c_flags       = $(CFLAGS) $(EXTRA_CFLAGS) $(CFLAGS_$(basetarget).o)
+_a_flags       = $(AFLAGS) $(EXTRA_AFLAGS) $(AFLAGS_$(basetarget).o)
 _cpp_flags     = $(CPPFLAGS) $(EXTRA_CPPFLAGS) $(CPPFLAGS_$(@F))
 
 # If building the kernel in a separate objtree expand all occurrences
diff --git a/scripts/Makefile.modpost b/scripts/Makefile.modpost
index 576cce5..e83613e 100644
--- a/scripts/Makefile.modpost
+++ b/scripts/Makefile.modpost
@@ -72,7 +72,7 @@ # Declare generated files as targets for
 # Step 5), compile all *.mod.c files
 
 # modname is set to make c_flags define KBUILD_MODNAME
-modname = $(*F)
+modname = $(basetarget)
 
 quiet_cmd_cc_o_c = CC      $@
       cmd_cc_o_c = $(CC) $(c_flags) $(CFLAGS_MODULE)	\
