From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Tue, 13 Jul 2004 15:18:30 +0000
Subject: Re: fix memory corruption/crash for physical-mode EFI calls
Message-Id: <200407131118.30269.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16623.29412.381259.793452@napali.hpl.hp.com>
In-Reply-To: <16623.29412.381259.793452@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday, July 13, 2004 10:54 am, Jack Steiner wrote:
> On Fri, Jul 09, 2004 at 09:39:00PM -0700, David Mosberger wrote:
> > Jesse,
> >
> > I think you'll want to try out the patch below.  If my guess is
> > correct and the SGI firmware doesn't support switching into virtual
> > mode, then this may fix the boot-problem you are seeing on SN2.
>
> FYI, I looked at the SGI boot failures that are occurring on recent 2.6
> kernels that have INIT_TASK in region 5. The boot failures are caused by a
> bug in our PROM. It incorrectly assumes that the stack is identity mapped.
> (Dont ask... :-)

Ugg, I remembered that we had code for calling in virtual or physical mode, 
but I should have checked to make sure it didn't assume identity mapping!

> We'll fix our PROM....

Thanks,
Jesse
