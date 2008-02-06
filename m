From: Russ Anderson <rja@sgi.com>
Date: Wed, 06 Feb 2008 23:32:02 +0000
Subject: Re: [patch] Fix large MCA bootmem allocation
Message-Id: <20080206233201.GA14501@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080205193232.GA8834@sgi.com>
In-Reply-To: <20080205193232.GA8834@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Feb 06, 2008 at 09:13:33AM -0600, Russ Anderson wrote:
> On Tue, Feb 05, 2008 at 04:00:09PM -0800, Luck, Tony wrote:
> > > Given that ia64_mca_cpu_init() does not get called in
> > > the hot-plug path
> > 
> > Surely it must be ...
> 
> That's what I thought, until testing showed otherwise.

My bad.  Additional testing shows ia64_mca_cpu_init() does get called.

I suspect my problem was when CONFIG_HOTPLUG_CPU was turned on,
not all the files were rebuilt.  
 
> The two code paths are setup_arch->cpu_init->ia64_mca_cpu_init
> for the boot processor and 
> start_secondary->cpu_init->ia64_mca_cpu_init for the other cpus
> at boot time.

In the hot-plug path, __cpu_up -> start_seconday .
 
> >                        you even have code in it to cope
> > with this case.  The:
> > 
> > 	if (__per_cpu_mca[cpu]) {
> > 
> > test can only be true if we are back in this code for a
> > second run through if the cpu was taken offline and added
> > again. Just like it says in the comment above this test.
> 
> Written on the assumption that the hot-plug code would
> eventually call it. 

It does.  The second time through the old memory is re-used.

Sorry about the noise...

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
