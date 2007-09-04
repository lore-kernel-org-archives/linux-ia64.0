From: "Natalie Protasevich" <protasnb@gmail.com>
Date: Tue, 04 Sep 2007 16:05:26 +0000
Subject: Re: [PATCH 1/1] Allow global purge traslation cache (ptc.g) to be disabled
Message-Id: <32209efe0709040905s5ebd57b1pa448e83e5f72dbe2@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200708301338.34246.protasnb@gmail.com>
In-Reply-To: <200708301338.34246.protasnb@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 03 Sep 2007 05:21:41 -0400, Jes Sorensen <jes@sgi.com> wrote:
> >>>>> "Natalie" = Natalie Protasevich <protasnb@gmail.com> writes:
>
> Natalie> From: Natalie Protasevich <protasnb@gmail.com>
>
> Natalie> This patch allows to disable ptc.g. The code used to be in
> Natalie> the kernel, then was removed in 2.4 since the bug that it was
> Natalie> fixing has gone away. However, some large system vendors now
> Natalie> want this capability available through a means that can be
> Natalie> controlled by the platform in the event that there is an
> Natalie> issue with either processor or their chipset where global
> Natalie> ptc.g is not operational.  They want the mechanism for future
> Natalie> platforms to work around such issues. It is also needed for
> Natalie> platform makers when they deliberately do not use the global
> Natalie> cache purge in their chipset implementation. (For such cases,
> Natalie> Intel provided a SAL table entry to specify if ptc.g is
> Natalie> allowed and how many).
>
> If you need a special TLB purge implementation, please use the machine
> vector as we do on the sn2 architecture - there is no reason to
> implement a boot time option for this.

The boot option is only temporary, until the SAL/PAL mechanism will be
shaken up.
I will digest and use the machvec then, how about that? For now I'd
like to provide this revived patch as is  for it is proven to be
working in the past, if you don't mind this first stage.

> Who are these large system vendors who want this patch in? I presume
> it's not the people running gmail? :-)

No :) those interested are big hardware makers of large scaled out
boxes, such as HP, UIS. They are using own asics and are not
necessarily being able to keep chipset native capabilities intact. As
I said in the preamble, the mechanism has to be there so they can turn
the ptc.g off and run the OS.
Regards,
--Natalie
>
> Cheers,
> Jes
>
