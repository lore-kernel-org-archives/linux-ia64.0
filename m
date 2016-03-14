From: Andy Lutomirski <luto@amacapital.net>
Date: Mon, 14 Mar 2016 04:28:55 +0000
Subject: Re: [PATCH] kbuild: drop FORCE from PHONY targets
Message-Id: <CALCETrVgSUy4ofeBmkZ7TurKvmQVX8C1aj__SLOL6SboQ3S-WA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1457828035-30584-1-git-send-email-yamada.masahiro@socionext.com>
 <CALCETrVqzidL7SXsCVm8wWrcQMR9dFOLGnDtC-eEYMO4a+yszA@mail.gmail.com> <CAK7LNARELkQbhAfBdh9Tx7gVGkpN9gTJzoqJwOF-0CH4zm+wcw@mail.gmail.com>
In-Reply-To: <CAK7LNARELkQbhAfBdh9Tx7gVGkpN9gTJzoqJwOF-0CH4zm+wcw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masahiro Yamada <yamada.masahiro@socionext.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Russell King <linux@arm.linux.org.uk>, Michal Marek <mmarek@suse.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-kbuild@vger.kernel.org" <linux-kbuild@vger.kernel.org>, Nathan Lynch <nathan_lynch@mentor.com>, Tony Luck <tony.luck@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>

On Sun, Mar 13, 2016 at 9:08 PM, Masahiro Yamada
<yamada.masahiro@socionext.com> wrote:
>
> Hi Andy
>
> 2016-03-14 9:39 GMT+09:00 Andy Lutomirski <luto@amacapital.net>:
> > On Mar 12, 2016 4:14 PM, "Masahiro Yamada"
> > <yamada.masahiro@socionext.com> wrote:
> >>
> >> These targets are marked as PHONY.  No need to add FORCE to their
> >> dependency.
> >
> > If this is, in fact, correct, can you update
> > Documentation/kbuild/makefiles.txt as well?
>
> Which line do you want me to update?
>

All the references to FORCE should probably mention .PHONY as an alternative.

--Andy

>
>
>
>
> --
> Best Regards
> Masahiro Yamada




-- 
Andy Lutomirski
AMA Capital Management, LLC
