From: "Siddha, Suresh B" <suresh.b.siddha@intel.com>
Date: Tue, 30 Mar 2004 07:51:41 +0000
Subject: RE: milstone reached: ia64 linux builds out of Linus' tree
Message-Id: <9AB83E4717F13F419BD880F5254709E5011EBA27@scsmsx402.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040330003052.GD2986@cse.unsw.EDU.AU>
In-Reply-To: <20040330003052.GD2986@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

We are working with the compiler team in getting all the compiler
options(required for kernel build) implemented and documented.

Jun has recently sent out the script
(http://www.ussg.iu.edu/hypermail/linux/kernel/0403.1/1428.html)
required for i386 kernel build. A similar script is required on IA64
side and ofcourse with IA64 specific options.

We will publish this script as soon as possible.

thanks,
suresh

> -----Original Message-----
> From: linux-ia64-owner@vger.kernel.org 
> [mailto:linux-ia64-owner@vger.kernel.org] On Behalf Of Jesse Barnes
> Sent: Monday, March 29, 2004 5:17 PM
> To: Peter Chubb
> Cc: Duraid Madina; Ian Wienand; linux-ia64@vger.kernel.org
> Subject: Re: milstone reached: ia64 linux builds out of Linus' tree
> 
> 
> On Monday 29 March 2004 5:03 pm, Peter Chubb wrote:
> > >>>>> "Duraid" = Duraid Madina <duraid@octopus.com.au> writes:
> >
> > Duraid> And for your next trick... any chance of adding an Intel C
> > Duraid> compiler version to the tinderbox?
> >
> > I'd love this to happen, but I haven't yet been able to build the
> > kernel with icc.
> >
> > If anyone out there has managed it, please document the result ---
> > maybe on our Wiki? http://www.gelato.unsw.edu.au/IA64wiki/
> 
> Yeah, this would be nice.  I received some secret instructions (Intel 
> apparently doesn't want some of the required compiler flags 
> to be made 
> public) on how to do this since I promised David I'd cleanup 
> the sn2 asm code 
> and use the compiler intrinsics, but I accidentally deleted 
> that mail before 
> I had a chance to do the cleanup...
> 
> Thanks,
> Jesse
> -
> To unsubscribe from this list: send the line "unsubscribe 
> linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
