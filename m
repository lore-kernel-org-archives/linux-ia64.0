From: Piet/Pete Delaney <piet@sgi.com>
Date: Thu, 07 Feb 2002 19:29:12 +0000
Subject: Re: [Linux-ia64] anyone maintaining lkcd for ia64?
Message-Id: <marc-linux-ia64-105590698806018@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698806015@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698806015@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Feb 07, 2002 at 10:51:26AM -0600, Robert K Gjertsen wrote:

Hi Rob:

I'm about 90% done on getting a preliminary version of lkcd working
for ia64. I hope to update the workspace shortly. I have to clean up
some of the changes I made to support the dump page size being smaller
that the virtual memory default page size. 

I hope to work out a put today with the EFI memory reading by lcrash,
how about I send you a copy tomarrow with some of the code cleaned up and
I'll check it in after I've made sure I haven't brooken ia32.

-piet

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

