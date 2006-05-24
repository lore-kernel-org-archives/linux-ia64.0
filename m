From: Rich Altmaier <richa@sgi.com>
Date: Wed, 24 May 2006 22:30:00 +0000
Subject: Re: dropping CONFIG_IA32_SUPPORT from ia64
Message-Id: <4474DE68.7010108@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200605241438.34303.bjorn.helgaas@hp.com>
In-Reply-To: <200605241438.34303.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I will offer the opinion that support of the IA32 ABI is
important.  That is, the ability to install and run
an IA32 binary (doesn't matter how, just matters it is
the same binary as used on an IA32 machine).
And I am certainly happy with the IA32-EL approach.

This feature provides a bridge for a customer with certainly
a lot more IA32 machines in their shop.  No customer will
have a dominate number of IA64 systems.  Hence the
ability for the IA64 to fit it and blend it, and run
any code there, and in addition do its special work,
is a much, much easier sell.
The reverse story, that IA64 runs only IA64 binaries,
is a tough sell.

Thanks!!
Rich
Rich Altmaier
VP of Engineering, SGI
richa@sgi.com


Peter Chubb wrote:

>>>>>>"Tony" = Tony Luck <Luck> writes:
> 
> 
> BH>> 
> BH>> Or maybe the people using ia32 compatibility are just running big
> BH>> apps like Firefox or Open Office that are non-trivial to build for
> BH>> ia64, but may not care as much about shiny new syscalls.
> 
> Tony> Firefox has been ported ... it came as a native ia64 binary rpm
> Tony> on the last OSD install disk that I put on my workstation.
> Tony> Dunno about Open office though.
> 
> Acrobat is the only thing I use it for...  and firefox when I *have*
> to view flash movies.
> 
> I think that IA32 support is important for those (few) of us who use
> Zx2000 or similar as workstations on Debian.  And I'm hoping that that
> number will increase now that some of the 2nd generation clusters are
> reaching eol, so there should be starting to be zx6000 on the 2nd hand
> market relatively cheap.  I've seen a few here for $1300AUD --- and
> even as old (1.2GHz) machines they beat the pants off anything else
> you can buy here at that price.
> 
> The new system calls are irrelevant for most apps.
> 
> --
> Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
> http://www.ertos.nicta.com.au           ERTOS within National ICT Australia
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
