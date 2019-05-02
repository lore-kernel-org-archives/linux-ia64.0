From: Pingfan Liu <kernelfans@gmail.com>
Date: Thu, 02 May 2019 06:22:06 +0000
Subject: Re: [PATCHv2] kernel/crash: make parse_crashkernel()'s return value more indicant
Message-Id: <CAFgQCTtQm7SuBRfXik6B065Aa+uQ=Mx6i+Y1q+NJU1GEiUgH4g@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1556087581-14513-1-git-send-email-kernelfans@gmail.com>
 <10dc5468-6cd9-85c7-ba66-1dfa5aa922b7@suse.com>
 <CAFgQCTstd667wP6g+maxYekz4u3iBR2R=FHUiS1V=XxTs6MKUw@mail.gmail.com>
In-Reply-To: <CAFgQCTstd667wP6g+maxYekz4u3iBR2R=FHUiS1V=XxTs6MKUw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthias Brugger <mbrugger@suse.com>
Cc: Rich Felker <dalias@libc.org>, linux-ia64@vger.kernel.org, Julien Thierry <julien.thierry@arm.com>, Yangtao Li <tiny.windzz@gmail.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Palmer Dabbelt <palmer@sifive.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Stefan Agner <stefan@agner.ch>, linux-mips@vger.kernel.org, Paul Mackerras <paulus@samba.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Logan Gunthorpe <logang@deltatee.com>, linux-s390@vger.kernel.org, Florian Fainelli <f.fainelli@gmail.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-sh@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, Russell King <linux@armlinux.org.uk>, Ingo Molnar <mingo@redhat.com>, Hari Bathini <hbathini@linux.ibm.com>, Catalin Marinas <catalin.marinas@arm.com>, James Hogan <jhogan@kernel.org>, Dave Young <dyoung@redhat.com>, Fenghua Yu <fenghua.yu@intel.com>, Will Deacon <will.deacon@arm.com>, Johannes Weiner <hannes@cmpxchg.org>, Ananth N Mavinakayanahalli <ananth@linux.vnet.ibm.com>, Borislav Petkov <bp@alien8.de>, David Hildenbrand <david@redhat.com>, linux-arm-kernel@lists.infradead.org, Jens Axboe <axboe@kernel.dk>, Tony Luck <tony.luck@intel.com>, Baoquan He <bhe@redhat.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Robin Murphy <robin.murphy@arm.com>, LKML <linux-kernel@vger.kernel.org>, Ralf Baechle <ralf@linux-mips.org>, Thomas Bogendoerfer <tbogendoerfer@suse.de>, Paul Burton <paul.burton@mips.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, Greg Hackmann <ghackmann@android.com>

On Thu, Apr 25, 2019 at 4:20 PM Pingfan Liu <kernelfans@gmail.com> wrote:
>
> On Wed, Apr 24, 2019 at 4:31 PM Matthias Brugger <mbrugger@suse.com> wrote:
> >
> >
> [...]
> > > @@ -139,6 +141,8 @@ static int __init parse_crashkernel_simple(char *cmdline,
> > >               pr_warn("crashkernel: unrecognized char: %c\n", *cur);
> > >               return -EINVAL;
> > >       }
> > > +     if (*crash_size = 0)
> > > +             return -EINVAL;
> >
> > This covers the case where I pass an argument like "crashkernel=0M" ?
> > Can't we fix that by using kstrtoull() in memparse and check if the return value
> > is < 0? In that case we could return without updating the retptr and we will be
> > fine.
After a series of work, I suddenly realized that it can not be done
like this way. "0M" causes kstrtoull() to return -EINVAL, but this is
caused by "M", not "0". If passing "0" to kstrtoull(), it will return
0 on success.

> >
> It seems that kstrtoull() treats 0M as invalid parameter, while
> simple_strtoull() does not.
>
My careless going through the code. And I tested with a valid value
"256M" using kstrtoull(), it also returned -EINVAL.

So I think there is no way to distinguish 0 from a positive value
inside this basic math function.
Do I miss anything?

Thanks and regards,
Pingfan
