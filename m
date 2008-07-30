From: Andrew Morton <akpm@linux-foundation.org>
Date: Wed, 30 Jul 2008 09:43:29 +0000
Subject: Re: [patch] IA64: only call up() in salinfo_work_to_do() if
Message-Id: <20080730024329.404eccc3.akpm@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080729094718.GA5247@verge.net.au>
	<1163.1217335629@ocs10w>
	<20080729130742.GA20158@verge.net.au>
In-Reply-To: <20080729130742.GA20158@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Keith Owens <kaos@ocs.com.au>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Tony Luck <tony.luck@intel.com>

On Tue, 29 Jul 2008 23:07:45 +1000 Simon Horman <horms@verge.net.au> wrote:

> On Tue, Jul 29, 2008 at 10:47:09PM +1000, Keith Owens wrote:
> > Simon Horman (on Tue, 29 Jul 2008 19:47:20 +1000) wrote:
> > >Aesthetic issues aside is it safe to call up() if down_trylock() failed?
> > >
> > >arch/ia64/kernel/salinfo.c: In function `salinfo_work_to_do':
> > >arch/ia64/kernel/salinfo.c:195: warning: ignoring return value of `down_trylock'
> > >
> > >Signed-off-by: Simon Horman <horms@verge.net.au>
> > >
> > >Index: linux-2.6/arch/ia64/kernel/salinfo.c
> > >=================================> > >--- linux-2.6.orig/arch/ia64/kernel/salinfo.c	2008-07-29 19:06:33.000000000 +1000
> > >+++ linux-2.6/arch/ia64/kernel/salinfo.c	2008-07-29 19:40:02.000000000 +1000
> > >@@ -192,8 +192,8 @@ struct salinfo_platform_oemdata_parms {
> > > static void
> > > salinfo_work_to_do(struct salinfo_data *data)
> > > {
> > >-	down_trylock(&data->mutex);
> > >-	up(&data->mutex);
> > >+	if (down_trylock(&data->mutex) = 0)
> > >+		up(&data->mutex);
> > > }
> > > 
> > > static void
> > 
> > NAK.  The whole point of this function is to set the mutex to the up
> > state, irrespective of whether it was already down or not.  Tracking
> > the state of data->mutex in all the possible contexts is just too
> > fragile, especially since it can be modified from NMI context.
> > salinfo_work_to_do() ensures that the mtuex ends in the up state.

boggle.  I daren't look.

> > To remove the warning, just stick '(void)' in front of down_trylock().
> 
> Thanks, will do.
> 

For gawd's sake add a comment there too.
