From: Guenter Roeck <linux@roeck-us.net>
Date: Mon, 11 Jan 2016 18:47:49 +0000
Subject: Re: [PATCH] efi: add conditional include of asm/early_ioremap.h
Message-Id: <20160111184749.GA15115@roeck-us.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1452456249-2974-1-git-send-email-ard.biesheuvel@linaro.org>
 <20160111144004.GD2644@codeblueprint.co.uk>
 <5693D52E.9090407@roeck-us.net>
 <CAKv+Gu9=yVNAVOLfuv135tu6anzNxGO8i7cdsLQ6PxUigNVU4g@mail.gmail.com>
In-Reply-To: <CAKv+Gu9=yVNAVOLfuv135tu6anzNxGO8i7cdsLQ6PxUigNVU4g-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ard Biesheuvel <ard.biesheuvel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Cc: "Williams, Dan J" <dan.j.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Matt Fleming <matt-mF/unelCI9GS6iBeEJttW/XRex20P6io@public.gmane.org>, "linux-efi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-efi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Will Deacon <will.deacon-5wv7dgnIgG8@public.gmane.org>, Fenghua Yu <fenghua.yu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Tony Luck <tony.luck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, "linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>

On Mon, Jan 11, 2016 at 06:35:44PM +0100, Ard Biesheuvel wrote:
[ ... ]

> >>
> >>
> >> I certainly can't think of a better way to fix this right now. Tony,
> >> Fenghua do you guys have any suggestions?
> >>
> >
> > How about including asm/early_ioremap.h from arch/arm/include/asm/io.h,
> > as it is done by arm64 and x86 ?
> >
> 
> That would work as well, but it does not address how early_memremap()
> is so poorly defined. I think the correct way would be to add the
> include unconditionally, and move ia64's definition to a new ia64
> version of early_ioremap.h

Depends on the definition of "poorly". Is the API exported through
asm/early_ioremap.h, or through asm/io.h ?

Guenter
