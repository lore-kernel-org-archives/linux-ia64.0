From: Matthew Wilcox <willy@debian.org>
Date: Thu, 03 Apr 2003 20:44:33 +0000
Subject: Re: [Linux-ia64] [PATCH] 2/4 pci segments
Message-Id: <marc-linux-ia64-105590723705405@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705394@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705394@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Apr 03, 2003 at 12:34:52PM -0800, David Mosberger wrote:
> >>>>> On Thu, 03 Apr 2003 10:51:38 -0700, Alex Williamson <alex_williamson@hp.com> said:
> 
> What's up with this hunk?
> 
>  	return "sn2";
>  # elif defined (CONFIG_IA64_DIG)
>  	return "dig";
> -# elif defined (CONFIG_IA64_HP_ZX1)
> -	return "hpzx1";
>  # else
>  #	error Unknown platform.  Fix acpi.c.
>  # endif

it's mentioned twice.  merge bug from 2.4.17 or so, iirc.

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk

