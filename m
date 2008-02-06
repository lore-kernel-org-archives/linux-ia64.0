From: Russ Anderson <rja@sgi.com>
Date: Wed, 06 Feb 2008 15:13:33 +0000
Subject: Re: [patch] Fix large MCA bootmem allocation
Message-Id: <20080206151332.GA6129@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080205193232.GA8834@sgi.com>
In-Reply-To: <20080205193232.GA8834@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Feb 05, 2008 at 04:00:09PM -0800, Luck, Tony wrote:
> > Given that ia64_mca_cpu_init() does not get called in
> > the hot-plug path
> 
> Surely it must be ...

That's what I thought, until testing showed otherwise.

The two code paths are setup_arch->cpu_init->ia64_mca_cpu_init
for the boot processor and 
start_secondary->cpu_init->ia64_mca_cpu_init for the other cpus
at boot time.

>                        you even have code in it to cope
> with this case.  The:
> 
> 	if (__per_cpu_mca[cpu]) {
> 
> test can only be true if we are back in this code for a
> second run through if the cpu was taken offline and added
> again. Just like it says in the comment above this test.

Written on the assumption that the hot-plug code would
eventually call it. 

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
