From: Russ Anderson <rja@sgi.com>
Date: Wed, 06 Apr 2005 19:28:09 +0000
Subject: Re: [patch] add MCA recovery on/off switch
Message-Id: <200504061928.j36JS95l9140537@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504060327.j363REMp8976934@clink.americas.sgi.com>
In-Reply-To: <200504060327.j363REMp8976934@clink.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jesse Barnes wrote:
> On Tuesday, April 5, 2005 8:32 pm, Randy.Dunlap wrote:
> > Russ Anderson wrote:
> > > Create /proc/sys/kernel/mca_recovery to turn on/off the MCA recovery
> > > code. This allows the recovery code to be enabled or disabled without
> > > having to reboot.
> >
> > Is there also a way to disable MCA recovery on the command line
> > as a boot option?  Using sysctl for it could be too late.
> 
> Yeah, we added the 'nomca' option a while back to disable machine check 
> recovery altogether, but it prevents it from being enabled later on iirc.

I've been convinced that the better way to turn the MCA recovery
code on/off is to build it as a module and insmod/rmmod.
That infrastructure already exists so there is no need for this patch.  
Sorry about the noise...

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
