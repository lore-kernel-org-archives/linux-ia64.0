From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 08 Jun 2007 20:52:07 +0000
Subject: RE: [IA64] Set default page size to 64k
Message-Id: <617E1C2C70743745A92448908E030B2A01A49CC7@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0706071803570.14490@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0706071803570.14490@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> SLUB can also take advantage of the larger page sizes. A kernel compile is 
> already ~5-10% faster with 16k. This will increase the speed even more. It 
> will also increase the effectiveness of slab reclaim because more objects 
> can be processed with a single acquisition of the dcache or inode lock.

I just built a 64K pagesize + SLUB kernel for my build system (4 socket
Montecito) and then used it to rebuild all my standard config kernels.
Comparing against a set of builds with a 16K pagesize + SLAB, the results
were a lot less impressive than implied by this and the "set SLUB as default"
postings.  Seven out of eleven builds were faster, but only by 3-6 seconds
(around 3% on a three minute build). Three builds were slower (by a similar
margin).  So I'd only rate the performance change as a "possible win, probably
doesn't hurt much" on this small system.

News from the performance team at Intel is also pretty guarded. You've
fixed the performance regressions we saw with earlier versions of SLUB
for Netperf and Volanomark.  Our favourite online transaction processing
benchmark is currently up about 1% against mainline+SLAB (though this is
just reclaiming the loss that SLAB has incurred since RHEL5 split off).

What do the big system numbers look like that have you so excited about
SLUB?

-Tony
