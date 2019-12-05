From: Masahiro Yamada <masahiroy@kernel.org>
Date: Thu, 05 Dec 2019 16:35:00 +0000
Subject: Re: [PATCH] x86/boot: kbuild: allow readelf executable to be specified
Message-Id: <CAK7LNATA=OsFVY7D9T_5qCv=2MKc5o4wto8HCd=2qScDAyRrgg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191204225446.202981-1-dima@golovin.in> <CAKwvOdm-bhuJMRRN3tyNdb88+_TFd4m3b-7gX0-91VG4djzp+Q@mail.gmail.com>
 <23883331575506134@vla1-3991b5027d7d.qloud-c.yandex.net>
In-Reply-To: <23883331575506134@vla1-3991b5027d7d.qloud-c.yandex.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dmitry Golovin <dima@golovin.in>
Cc: Nick Desaulniers <ndesaulniers@google.com>, Michal Marek <michal.lkml@markovi.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, "maintainer:X86 ARCHITECTURE (32-BIT AND 64-BIT)" <x86@kernel.org>, Bruce Ashfield <bruce.ashfield@gmail.com>, Ross Philipson <ross.philipson@oracle.com>, Ross Burton <ross.burton@intel.com>, Chao Fan <fanc.fnst@cn.fujitsu.com>, Daniel Kiper <daniel.kiper@oracle.com>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, clang-built-linux <clang-built-linux@googlegroups.com>, "tony.luck@intel.com" <tony.luck@intel.com>, "fenghua.yu@intel.com" <fenghua.yu@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

On Thu, Dec 5, 2019 at 9:41 AM Dmitry Golovin <dima@golovin.in> wrote:
>
> 05.12.2019, 01:18, "'Nick Desaulniers' via Clang Built Linux" <clang-built-linux@googlegroups.com>:
> >
> > Grepping the kernel sources for `READELF`, it looks like
> > arch/ia64/Makefile makes the same mistake. Would you mind fixing both
> > cases in the same patch (v2)? I'm also curious about it's use in
> > arch/ia64/scripts/unwcheck.py, and scripts/faddr2line. +ia64
> > maintainers and list.
> >
> > I think if you simply remove the assignment on line 17 of
> > arch/ia64/Makefile you should be fine.
>
> Perhaps something should be done to NM on line 16 of this file as well. Also
> found similar invocation of `objcopy` in arch/riscv/kernel/vdso/Makefile.
> I think IA64 and RISC-V changes should be made as separate commits.
>
> -- Dmitry

I am fine with either way.
I can take this patch, and also a one for IA64.

You can send a patch for arch/riscv/kernel/vdso/Makefile
to the riscv maintainer since it has no patch dependency.


-- 
Best Regards
Masahiro Yamada
