From: Nick Desaulniers <ndesaulniers@google.com>
Date: Wed, 08 May 2019 19:22:39 +0000
Subject: Re: [PATCH] ia64: require -Wl,--hash-style=sysv
Message-Id: <CAKwvOd=tA3-i65B_92QHaJrpEREzBB91QkkqgRANncwfb2d-Kg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190423204821.241925-1-ndesaulniers@google.com> <CAKwvOd=ws1D95ydQjGtK0U0KQ-5poyj8Oek5Yka6-cvtCdpJ-g@mail.gmail.com>
In-Reply-To: <CAKwvOd=ws1D95ydQjGtK0U0KQ-5poyj8Oek5Yka6-cvtCdpJ-g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com, fenghua.yu@intel.com
Cc: clang-built-linux <clang-built-linux@googlegroups.com>, Masahiro Yamada <yamada.masahiro@socionext.com>, linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

bumping for review, as the merge window is now open.

On Tue, Apr 30, 2019 at 1:24 PM Nick Desaulniers
<ndesaulniers@google.com> wrote:
>
> On Tue, Apr 23, 2019 at 1:48 PM Nick Desaulniers
> <ndesaulniers@google.com> wrote:
> >
> > Towards the goal of removing cc-ldoption, it seems that --hash-style> > was added to binutils 2.17.50.0.2 in 2006. The minimal required version
> > of binutils for the kernel according to
> > Documentation/process/changes.rst is 2.20.
> >
> > Link: https://gcc.gnu.org/ml/gcc/2007-01/msg01141.html
> > Cc: clang-built-linux@googlegroups.com
> > Suggested-by: Masahiro Yamada <yamada.masahiro@socionext.com>
> > Signed-off-by: Nick Desaulniers <ndesaulniers@google.com>
> > ---
> >  arch/ia64/kernel/Makefile.gate | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> >
> > diff --git a/arch/ia64/kernel/Makefile.gate b/arch/ia64/kernel/Makefile.gate
> > index f53faf48b7ce..846867bff6d6 100644
> > --- a/arch/ia64/kernel/Makefile.gate
> > +++ b/arch/ia64/kernel/Makefile.gate
> > @@ -11,7 +11,7 @@ quiet_cmd_gate = GATE    $@
> >        cmd_gate = $(CC) -nostdlib $(GATECFLAGS_$(@F)) -Wl,-T,$(filter-out FORCE,$^) -o $@
> >
> >  GATECFLAGS_gate.so = -shared -s -Wl,-soname=linux-gate.so.1 \
> > -                    $(call cc-ldoption, -Wl$(comma)--hash-style=sysv)
> > +                    -Wl,--hash-style=sysv
> >  $(obj)/gate.so: $(obj)/gate.lds $(obj)/gate.o FORCE
> >         $(call if_changed,gate)
> >
> > --
> > 2.21.0.593.g511ec345e18-goog
> >
>
> bumping for review
>
> --
> Thanks,
> ~Nick Desaulniers



-- 
Thanks,
~Nick Desaulniers
