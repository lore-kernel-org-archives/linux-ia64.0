From: Russ Anderson <rja@sgi.com>
Date: Fri, 04 Feb 2005 16:34:48 +0000
Subject: Re: [patch] fix per-CPU MCA mess and make UP kernels work again
Message-Id: <200502041634.j14GYmKh18121098@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16887.1203.470842.161249@napali.hpl.hp.com>
In-Reply-To: <16887.1203.470842.161249@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: linux-ia64@vger.kernel.org

Jack Steiner wrote:
> On Fri, Feb 04, 2005 at 02:00:15PM +1100, Keith Owens wrote:
> 
> To further muddy the waters, it looks like the latest Error Handling Guide
> has addressed the issue:
> 
> >> Intel® Itanium® Processor Family Error Handling Guide April 2004
> >>
> >> Document Number: 249278-003
> >>
> >> 2.7.1
> >>
> >> ...
> >> The MCA error information is provided to the OS_MCA layer. The MCA
> >> error record is logged to the NVM.  To simplify SAL implementation, it
> >> is strongly recommended that SAL process all MCAs by handing off to the
> >> OS as soon as possible to prevent some OSes from experiencing time-outs
> >> and potentially crashing the system. >>>> The SAL may maintain a variable in
> >> the SAL data area that indicates whether SAL, on one of the processors,
> >> is already handling an MCA. If so, MCA processing on other processors will
> >> wait within the SAL MCA handler until the current MCA is processed. This
> >> situation may arise when local MCAs are experienced on multiple
> >> processors. <<<<<<<
> 
> 
> However, it says "may maintain a variable...".  Should I interpret this as 
> allowing but not requiring serialization?

I vote for that interpritation.  IMHO, Linux needs to continue to support
SALs that single thread MCAs, but should also allow concurrent MCA
handling for SALs that support it.


-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
