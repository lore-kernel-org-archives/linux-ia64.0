From: "Tom Morano" <tjm@sgi.com>
Date: Thu, 07 Feb 2002 18:14:05 +0000
Subject: Re: [Linux-ia64] anyone maintaining lkcd for ia64?
Message-Id: <marc-linux-ia64-105590698806017@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698806015@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698806015@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Rob,

No, SGI has not dumped working on an ia64 version of LKCD. Piet Delaney is
the engineer primarily working on getting the latest LKCD kernel code
integrated and working with the latest Linux kernel rev. I've Cc'd him on
this response. If you have any questions, issues, or suggestions regarding
this effort, please contact Piet directly.

Thanks,

Tom

----- Original Message -----
From: "Robert K Gjertsen" <gjertsen@us.ibm.com>
To: <linux-ia64@linuxia64.org>
Sent: Thursday, February 07, 2002 8:51 AM
Subject: [Linux-ia64] anyone maintaining lkcd for ia64?


> I've used kdb in the past for ia64, but was
> taking a look at getting lkcd working on RH 7.2
> (2.4.9-18/21) for ia64.
> I grabbed the latest stuff from sourceforge.net
> and I'm working through the patched build now
> and see that dump_base.c is ia64 unfriendly
> with its use of irq_stat (using a hacked patch
> originally from lkcd-2.4.15-1.diff).
> I'm slogging through this, but I hate to reinvent
> the wheel if someone else has a working
> copy/patch (newer kernel version is fine).
> Anyone actually using this for newer kernels
> on ia64 (and has SGI totally dumped working
> on this)?
>
> Thanks,
>
> --Rob
>
>
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
>


