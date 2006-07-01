From: "David Mosberger-Tang" <David.Mosberger@acm.org>
Date: Sat, 01 Jul 2006 03:46:32 +0000
Subject: Re: ia64 breakage in current -git
Message-Id: <ed5aea430606302046w28f905fdn62d2b53498511410@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060627010646.21ff5687.akpm@osdl.org>
In-Reply-To: <20060627010646.21ff5687.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Sam,

I build- and boot-tested this patch on a zx2000.  Seems to work fine.

Thanks!

  --david

On 6/30/06, Sam Ravnborg <sam@ravnborg.org> wrote:
> Crap.
> Ignore the last patch I sent - it was the old one which is buggy.
> The following is the right one (did I say it was past midnight...)
>
>         Sam
>
> diff --git a/Makefile b/Makefile
> index e9560c6..c4ea9cd 100644
> --- a/Makefile
> +++ b/Makefile
> @@ -1352,7 +1352,7 @@ quiet_cmd_rmfiles = $(if $(wildcard $(rm
>
>  a_flags = -Wp,-MD,$(depfile) $(AFLAGS) $(AFLAGS_KERNEL) \
>           $(NOSTDINC_FLAGS) $(CPPFLAGS) \
> -         $(modkern_aflags) $(EXTRA_AFLAGS) $(AFLAGS_$(*F).o)
> +         $(modkern_aflags) $(EXTRA_AFLAGS) $(AFLAGS_$(notdir $@))
>
>  quiet_cmd_as_o_S = AS      $@
>  cmd_as_o_S       = $(CC) $(a_flags) -c -o $@ $<
> diff --git a/arch/um/scripts/Makefile.rules b/arch/um/scripts/Makefile.rules
> index 1347dc6..813077f 100644
> --- a/arch/um/scripts/Makefile.rules
> +++ b/arch/um/scripts/Makefile.rules
> @@ -8,7 +8,7 @@ USER_OBJS += $(filter %_user.o,$(obj-y)
>  USER_OBJS := $(foreach file,$(USER_OBJS),$(obj)/$(file))
>
>  $(USER_OBJS:.o=.%): \
> -       c_flags = -Wp,-MD,$(depfile) $(USER_CFLAGS) $(CFLAGS_$(*F).o)
> +       c_flags = -Wp,-MD,$(depfile) $(USER_CFLAGS) $(CFLAGS_$(basetarget).o)
>  $(USER_OBJS) : CHECKFLAGS := -D__linux__ -Dlinux -D__STDC__ \
>         -Dunix -D__unix__ -D__$(SUBARCH)__
>
> @@ -17,7 +17,7 @@ # using it directly.
>  UNPROFILE_OBJS := $(foreach file,$(UNPROFILE_OBJS),$(obj)/$(file))
>
>  $(UNPROFILE_OBJS:.o=.%): \
> -       c_flags = -Wp,-MD,$(depfile) $(call unprofile,$(USER_CFLAGS)) $(CFLAGS_$(*F).o)
> +       c_flags = -Wp,-MD,$(depfile) $(call unprofile,$(USER_CFLAGS)) $(CFLAGS_$(basetarget).o)
>  $(UNPROFILE_OBJS) : CHECKFLAGS := -D__linux__ -Dlinux -D__STDC__ \
>         -Dunix -D__unix__ -D__$(SUBARCH)__
>
> diff --git a/scripts/Kbuild.include b/scripts/Kbuild.include
> index b0d067b..2180c88 100644
> --- a/scripts/Kbuild.include
> +++ b/scripts/Kbuild.include
> @@ -13,6 +13,10 @@ # contain a comma
>  depfile = $(subst $(comma),_,$(@D)/.$(@F).d)
>
>  ###
> +# filename of target with directory and extension stripped
> +basetarget = $(basename $(notdir $@))
> +
> +###
>  # Escape single quote for use in echo statements
>  escsq = $(subst $(squote),'\$(squote)',$1)
>
> diff --git a/scripts/Makefile.build b/scripts/Makefile.build
> index 02a7eea..3cb445c 100644
> --- a/scripts/Makefile.build
> +++ b/scripts/Makefile.build
> @@ -117,7 +117,7 @@ quiet_modtag := $(empty)   $(empty)
>  $(obj-m)              : quiet_modtag := [M]
>
>  # Default for not multi-part modules
> -modname = $(*F)
> +modname = $(basetarget)
>
>  $(multi-objs-m)         : modname = $(modname-multi)
>  $(multi-objs-m:.o=.i)   : modname = $(modname-multi)
> diff --git a/scripts/Makefile.host b/scripts/Makefile.host
> index 2b066d1..18ecd4d 100644
> --- a/scripts/Makefile.host
> +++ b/scripts/Makefile.host
> @@ -80,8 +80,10 @@ obj-dirs += $(host-objdirs)
>  #####
>  # Handle options to gcc. Support building with separate output directory
>
> -_hostc_flags   = $(HOSTCFLAGS)   $(HOST_EXTRACFLAGS)   $(HOSTCFLAGS_$(*F).o)
> -_hostcxx_flags = $(HOSTCXXFLAGS) $(HOST_EXTRACXXFLAGS) $(HOSTCXXFLAGS_$(*F).o)
> +_hostc_flags   = $(HOSTCFLAGS)   $(HOST_EXTRACFLAGS)   \
> +                 $(HOSTCFLAGS_$(basetarget).o)
> +_hostcxx_flags = $(HOSTCXXFLAGS) $(HOST_EXTRACXXFLAGS) \
> +                 $(HOSTCXXFLAGS_$(basetarget).o)
>
>  ifeq ($(KBUILD_SRC),)
>  __hostc_flags  = $(_hostc_flags)
> diff --git a/scripts/Makefile.lib b/scripts/Makefile.lib
> index 2cb4935..fc498fe 100644
> --- a/scripts/Makefile.lib
> +++ b/scripts/Makefile.lib
> @@ -82,12 +82,12 @@ # Note: It's possible that one object ge
>  #       than one module. In that case KBUILD_MODNAME will be set to foo_bar,
>  #       where foo and bar are the name of the modules.
>  name-fix = $(subst $(comma),_,$(subst -,_,$1))
> -basename_flags = -D"KBUILD_BASENAME=KBUILD_STR($(call name-fix,$(*F)))"
> +basename_flags = -D"KBUILD_BASENAME=KBUILD_STR($(call name-fix,$(basetarget)))"
>  modname_flags  = $(if $(filter 1,$(words $(modname))),\
>                   -D"KBUILD_MODNAME=KBUILD_STR($(call name-fix,$(modname)))")
>
> -_c_flags       = $(CFLAGS) $(EXTRA_CFLAGS) $(CFLAGS_$(*F).o)
> -_a_flags       = $(AFLAGS) $(EXTRA_AFLAGS) $(AFLAGS_$(*F).o)
> +_c_flags       = $(CFLAGS) $(EXTRA_CFLAGS) $(CFLAGS_$(basetarget).o)
> +_a_flags       = $(AFLAGS) $(EXTRA_AFLAGS) $(AFLAGS_$(basetarget).o)
>  _cpp_flags     = $(CPPFLAGS) $(EXTRA_CPPFLAGS) $(CPPFLAGS_$(@F))
>
>  # If building the kernel in a separate objtree expand all occurrences
> diff --git a/scripts/Makefile.modpost b/scripts/Makefile.modpost
> index 576cce5..a495502 100644
> --- a/scripts/Makefile.modpost
> +++ b/scripts/Makefile.modpost
> @@ -72,7 +72,7 @@ # Declare generated files as targets for
>  # Step 5), compile all *.mod.c files
>
>  # modname is set to make c_flags define KBUILD_MODNAME
> -modname = $(*F)
> +modname = $(notdir $(@:.mod.o=))
>
>  quiet_cmd_cc_o_c = CC      $@
>        cmd_cc_o_c = $(CC) $(c_flags) $(CFLAGS_MODULE)   \
>


-- 
Mosberger Consulting LLC, http://www.mosberger-consulting.com/
