From: Alex Williamson <alex_williamson@hp.com>
Date: Thu, 03 Apr 2003 20:42:33 +0000
Subject: Re: [Linux-ia64] [PATCH] 2/4 pci segments
Message-Id: <marc-linux-ia64-105590723705409@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705394@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705394@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

   Removing a dup, this is what it looks like in the 2.5.64 tree:

# if defined (CONFIG_IA64_HP_SIM)
        return "hpsim";
# elif defined (CONFIG_IA64_HP_ZX1)
        return "hpzx1";
# elif defined (CONFIG_IA64_SGI_SN1)
        return "sn1";
# elif defined (CONFIG_IA64_SGI_SN2)
        return "sn2";
# elif defined (CONFIG_IA64_DIG)
        return "dig";
# elif defined (CONFIG_IA64_HP_ZX1)
        return "hpzx1";

Thanks,

	Alex

David Mosberger wrote:
> 
> >>>>> On Thu, 03 Apr 2003 10:51:38 -0700, Alex Williamson <alex_williamson@hp.com> said:
> 
> What's up with this hunk?
> 
>         return "sn2";
>  # elif defined (CONFIG_IA64_DIG)
>         return "dig";
> -# elif defined (CONFIG_IA64_HP_ZX1)
> -       return "hpzx1";
>  # else
>  #      error Unknown platform.  Fix acpi.c.
>  # endif
> 
>         --david

--
Alex Williamson                             HP Linux & Open Source Lab

