From: Keith Owens <kaos@ocs.com.au>
Date: Tue, 23 Jul 2002 05:58:58 +0000
Subject: Re: [Linux-ia64] kernel update (relative to v2.4.18)
Message-Id: <marc-linux-ia64-105590701905814@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 22 Jul 2002 22:04:16 -0700, 
David Mosberger <davidm@napali.hpl.hp.com> wrote:
>>>>>> On Tue, 23 Jul 2002 13:09:24 +1000, Keith Owens <kaos@ocs.com.au> said:
>  Keith> * Moves force setting of DEVFS for SN[12] to fs/Config.in.
>
>  Keith> * Removes the attempt to set BLOCK variables from
>  Keith> arch/ia64/config.in and adds the dependency on HP_SIM to
>  Keith> drivers/block/Config.in.  This is the only method that stands
>  Keith> any chance of working for xconfig.  ACPI is already done this
>  Keith> way for the same reason, the arch dependencies are inside the
>  Keith> ACPI menu, not in the arch menu.
>
>Now these I really don't like.  I don't think it's good to clutter
>platform-independent config files with platform-specific info just
>because xconfig is broken.  As far as I know, these things work
>perfectly fine with "oldconfig", "config", and "menuconfig".  (I don't
>feel as strongly about this for DEVFS as I do for HP_SIM; but clearly
>HP_SIM is such a special case that I'd prefer to keep it in the
>ia64-specific config file.)

I agree, but given the restrictions of CML1, there is no choice.  The
problem is not just xconfig, it affects menuconfig as well.  Before
this patch, arch/ia64/config.in set DEVFS=y for SN[12] but there was
nothing stopping a user changing DEVFS in the fs menu.  Other cross
menu dependencies have the same problem with any config system that
allows out of order evaluation.

CML1 does _not_ enforce dependencies across menus, the dependencies
have to be in a single menu.  This was one of the driving forces behind
CML2, to get some method for doing cross menu constraints.  Without
CML2, we have to scatter arch dependent code over generic config menus :(.


