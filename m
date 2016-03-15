From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 15 Mar 2016 18:27:56 +0000
Subject: Re: [PATCH] kbuild: drop FORCE from PHONY targets
Message-Id: <CALCETrVNMv5XwpXTJcevVLCfTSMbsqKsjzzukoGr7VAHuumFpg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1457828035-30584-1-git-send-email-yamada.masahiro@socionext.com>
 <CALCETrVqzidL7SXsCVm8wWrcQMR9dFOLGnDtC-eEYMO4a+yszA@mail.gmail.com>
 <CAK7LNARELkQbhAfBdh9Tx7gVGkpN9gTJzoqJwOF-0CH4zm+wcw@mail.gmail.com>
 <CALCETrVgSUy4ofeBmkZ7TurKvmQVX8C1aj__SLOL6SboQ3S-WA@mail.gmail.com>
 <CAK7LNAQOJjcn7Q+s_pKqzUuojMBtOsRNKsmVwDFXvTeU-zvSeQ@mail.gmail.com>
 <CALCETrU+6sj=reBgPBy7Mq6KYY7BKkVLGwm4XrVzOzb8aU+meg@mail.gmail.com> <CAK7LNATAeMmfwWiZha17mbyWhF6bR5RGjv+gbsQTvL4teoTiPQ@mail.gmail.com>
In-Reply-To: <CAK7LNATAeMmfwWiZha17mbyWhF6bR5RGjv+gbsQTvL4teoTiPQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masahiro Yamada <yamada.masahiro@socionext.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Russell King <linux@arm.linux.org.uk>, Ingo Molnar <mingo@redhat.com>, Michal Marek <mmarek@suse.com>, X86 ML <x86@kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Tony Luck <tony.luck@intel.com>, Nathan Lynch <nathan_lynch@mentor.com>, "linux-kbuild@vger.kernel.org" <linux-kbuild@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "H. Peter Anvin" <hpa@zytor.com>

On Mar 13, 2016 11:26 PM, "Masahiro Yamada"
<yamada.masahiro@socionext.com> wrote:
>
> Hi Andy,
>
>
> 2016-03-14 13:44 GMT+09:00 Andy Lutomirski <luto@amacapital.net>:
> > On Sun, Mar 13, 2016 at 9:36 PM, Masahiro Yamada
> > <yamada.masahiro@socionext.com> wrote:
> >> 2016-03-14 13:28 GMT+09:00 Andy Lutomirski <luto@amacapital.net>:
> >>> On Sun, Mar 13, 2016 at 9:08 PM, Masahiro Yamada
> >>> <yamada.masahiro@socionext.com> wrote:
> >>>>
> >>>> Hi Andy
> >>>>
> >>>> 2016-03-14 9:39 GMT+09:00 Andy Lutomirski <luto@amacapital.net>:
> >>>> > On Mar 12, 2016 4:14 PM, "Masahiro Yamada"
> >>>> > <yamada.masahiro@socionext.com> wrote:
> >>>> >>
> >>>> >> These targets are marked as PHONY.  No need to add FORCE to their
> >>>> >> dependency.
> >>>> >
> >>>> > If this is, in fact, correct, can you update
> >>>> > Documentation/kbuild/makefiles.txt as well?
> >>>>
> >>>> Which line do you want me to update?
> >>>>
> >>>
> >>> All the references to FORCE should probably mention .PHONY as an alternative.
> >>
> >> I do not get your point.
> >>
> >> All the examples in the makefile.txt correctly reference to FORCE.
> >> They are not PHONY targets.
> >> No need to update.
> >
> > But they could be.  For example:
> >
> >                 $(obj)/image: vmlinux FORCE
> >                         $(call if_changed,objcopy)
> >
> > could be:
> >
> >                  .PHONY: $(obj)/image
> >                 $(obj)/image: vmlinux
> >                         $(call if_changed,objcopy)
> >
> > I would at least change:
> >
> > Note: It is a typical mistake to forget the FORCE prerequisite.
> >
> > to:
> >
> > Note: if-changed is only useful if make executes it, which won't
> > happen if it determines that the inputs have not changed since the
> > output was built.  This can be avoided by specifying FORCE as a
> > prerequisite or by making declaring the output as .PHONY.
> >
>
>
> No. This is absolutely wrong.
> PHONY and FORCE are not interchangeable.
>
> They have different behavior.
> I will show you how they behave differently.
>
>
> BTW, Linux 4.5 is out now.
>
> Let's try a simple experiment on it.
>
>
> The following shows that my source tree is v4.5
>
> yamada@beagle:~/workspace/linux$ git describe
> v4.5
>
>
>
> Example 1)
>
>
> Add the following code to the top Makefile.
>
> Please note "FORCE" is used here.
>
>
> yamada@beagle:~/workspace/linux$ git diff
> diff --git a/Makefile b/Makefile
> index 7b3ecdc..89b7d0d 100644
> --- a/Makefile
> +++ b/Makefile
> @@ -914,6 +914,22 @@ export KBUILD_ALLDIRS := $(sort $(filter-out
> arch/%,$(vmlinux-
>
>  vmlinux-deps := $(KBUILD_LDS) $(KBUILD_VMLINUX_INIT) $(KBUILD_VMLINUX_MAIN)
>
> +quiet_cmd_gen_foo = FOO     $@
> +      cmd_gen_foo = (cat $<; echo hello) > $@
> +
> +foo: bar FORCE
> +       $(call if_changed,gen_foo)
> +
> +quiet_cmd_gen_bar = BAR     $@
> +      cmd_gen_bar = (cat $<; echo $(GREETING)) > $@
> +
> +bar: baz FORCE
> +       $(call if_changed,gen_bar)
> +
> +baz:
> +       @touch $@
> +
> +
>  # Final link of vmlinux
>        cmd_link-vmlinux = $(CONFIG_SHELL) $< $(LD) $(LDFLAGS) $(LDFLAGS_vmlinux)
>  quiet_cmd_link-vmlinux = LINK    $@
>
>
>
> Try the following.
>
> yamada@beagle:~/workspace/linux$ git clean -x -f
> yamada@beagle:~/workspace/linux$ make -s defconfig
> yamada@beagle:~/workspace/linux$ make GREETING=GoodMorning foo
> scripts/kconfig/conf  --silentoldconfig Kconfig
>   BAR     bar
>   FOO     foo
> yamada@beagle:~/workspace/linux$ make GREETING=GoodMorning foo
> make: `foo' is up to date.
> yamada@beagle:~/workspace/linux$ make GREETING=GoodAfternoon foo
>   BAR     bar
>   FOO     foo
> yamada@beagle:~/workspace/linux$ make GREETING=GoodAfternoon foo
> make: `foo' is up to date.
> yamada@beagle:~/workspace/linux$ make GREETING=GoodEvening foo
>   BAR     bar
>   FOO     foo
> yamada@beagle:~/workspace/linux$ make GREETING=GoodEvening foo
> make: `foo' is up to date.
>
>
>
>
> Please notice "foo" and "bar" were not rebuilt
> when I gave the same command line as the previous run.
>
>
> When I changed the command line, "bar"  was update
> and "foo" was also updated because "foo" depends on "bar".
>
>
> It means $(call if_changed,...) is working as expected.
>
>
>
>
>
>
> Example 2)
>
>
> Add the following to the top Makefile.
> Please notice that I just replaced "FORCE" with ".PHONY".
>
>
>
> diff --git a/Makefile b/Makefile
> index 7b3ecdc..a0899c3 100644
> --- a/Makefile
> +++ b/Makefile
> @@ -914,6 +914,24 @@ export KBUILD_ALLDIRS := $(sort $(filter-out
> arch/%,$(vmlinux-
>
>  vmlinux-deps := $(KBUILD_LDS) $(KBUILD_VMLINUX_INIT) $(KBUILD_VMLINUX_MAIN)
>
> +quiet_cmd_gen_foo = FOO     $@
> +      cmd_gen_foo = (cat $<; echo hello) > $@
> +
> +.PHONY: foo
> +foo: bar
> +       $(call if_changed,gen_foo)
> +
> +quiet_cmd_gen_bar = BAR     $@
> +      cmd_gen_bar = (cat $<; echo $(GREETING)) > $@
> +
> +.PHONY: bar
> +bar: baz
> +       $(call if_changed,gen_bar)
> +
> +baz:
> +       @touch $@
> +
> +
>  # Final link of vmlinux
>        cmd_link-vmlinux = $(CONFIG_SHELL) $< $(LD) $(LDFLAGS) $(LDFLAGS_vmlinux)
>  quiet_cmd_link-vmlinux = LINK    $@
>
>
>
> Let's try the same thing.
>
>
>
> yamada@beagle:~/workspace/linux$ git clean -x -f
> yamada@beagle:~/workspace/linux$ make -s defconfig
> yamada@beagle:~/workspace/linux$ make GREETING=GoodMorning foo
> scripts/kconfig/conf  --silentoldconfig Kconfig
>   BAR     bar
>   FOO     foo
> yamada@beagle:~/workspace/linux$ make GREETING=GoodMorning foo
>   BAR     bar
>   FOO     foo
> yamada@beagle:~/workspace/linux$ make GREETING=GoodMorning foo
>   BAR     bar
>   FOO     foo
> yamada@beagle:~/workspace/linux$ make GREETING=GoodAfternoon foo
>   BAR     bar
>   FOO     foo
> yamada@beagle:~/workspace/linux$ make GREETING=GoodAfternoon foo
>   BAR     bar
>   FOO     foo
> yamada@beagle:~/workspace/linux$ make GREETING=GoodAfternoon foo
>   BAR     bar
>   FOO     foo
>
>
> Did you notice the difference?
>
> The "foo" and "bar" are always rebuilt
> regardless the command line is changed or not.
>
> It means $(call if_changed,...) is not working.
>

Fair enough, although I'm curious why this happens.  It might be worth
changing the docs to say that .PHONY is *not* an substitute for FORCE
in that context, then.

--Andy
