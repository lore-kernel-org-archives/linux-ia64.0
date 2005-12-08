From: Christoph Lameter <clameter@engr.sgi.com>
Date: Thu, 08 Dec 2005 23:19:36 +0000
Subject: Re: [PATCH 1/3] Zone reclaim V3: main patch
Message-Id: <Pine.LNX.4.62.0512081514510.31246@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051208203707.30456.57439.sendpatchset@schroedinger.engr.sgi.com>
 <20051208210850.GS11190@wotan.suse.de> <Pine.LNX.4.62.0512081320200.30786@schroedinger.engr.sgi.com>
 <20051208225102.GW11190@wotan.suse.de>
In-Reply-To: <20051208225102.GW11190@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@suse.de>
Cc: akpm@osdl.org, Christoph Hellwig <hch@infradead.org>, linux-ia64@vger.kernel.org, steiner@sgi.com, linux-kernel@vger.kernel.org, Wu Fengguang <wfg@mail.ustc.edu.cn>, discuss@x86-64.org

On Thu, 8 Dec 2005, Andi Kleen wrote:

> I would use > LOCAL_DISTANCE or perhaps if you really want
> a new constant with value 12-15. 

One may define RECLAIM_DISTANCE to be 12 for x86_64 in topology.h
in order to get zone reclaim earlier for the opteron clusters. I would 
think though that large opteron clusters also have distances > 20.

My experience is that at 20 systems do not need zone reclaim yet.
 
> > RECLAIM_DISTANCE can be set per arch if the default is not okay.
> 
> Well if anything it would be per system - perhaps need to make
> it a boot option or somesuch later. 

The idea here was to avoid any manual configuration. The numa distances 
must related in some real way to performance (at least per arch) in order 
for the automatic determination of zone reclaim to make sense. We could 
have a boot time override but then RECLAIM_DISTANCE needs to be a 
variable not a macro.


