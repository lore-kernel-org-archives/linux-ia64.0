From: Matthias Fouquet-Lapar <mfl@kernel.paris.sgi.com>
Date: Sun, 16 Jan 2005 09:01:43 +0000
Subject: Re: [patch] Remove limit on MCA recoveries
Message-Id: <200501160901.j0G91h8G001716@mtv-vpn-hw-mfl-1.corp.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501152249.j0FMn6JH2857539@clink.americas.sgi.com>
In-Reply-To: <200501152249.j0FMn6JH2857539@clink.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> On Sat, 15 Jan 2005 16:49:06 -0600 (CST), 
> Russ Anderson <rja@sgi.com> wrote:
> >The MCA recovery driver saves addresses memory errors
> >in an array.  The array has 32 entries.  The effect is 
> >that after 32 recoveries, the driver stops recovering.
> >
> >This patch removes the page_isolate array.  Since the array
> >was only used to see if the page is already marked reserved,
> >check the reserved bit instead of the array.
> 
> lkcd dumps kernel pages marked reserved, so lkcd will try to process
> isolated pages.  We will eventually need to add a new page flag to mark
> faulty pages.

Probably any other dump mechanism should be aware of bad HW pages as well,
so we might be better off to add a flag right away. While we are at it I
would propose to have actually two flags :

  - hard error (which will cause a MCA and should be skipped when taking
                a system dump)
  - soft error (page has encountered SBE, so we might want to avoid future
                allocation, but it can be dumped without causing an MCA)

Then we need to define some API that this information can be saved accross
a reboot, so we don't have to have another process hitting the UCE to find
out that there really is a problem at that location

Thanks

Matthias Fouquet-Lapar  Core Platform Software    mfl@sgi.com  VNET 521-8213
Principal Engineer      Silicon Graphics          Home Office (+33) 1 3047 4127

