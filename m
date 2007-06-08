From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 08 Jun 2007 21:02:02 +0000
Subject: RE: [IA64] Set default page size to 64k
Message-Id: <Pine.LNX.4.64.0706081356130.3178@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0706071803570.14490@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0706071803570.14490@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 8 Jun 2007, Luck, Tony wrote:

> News from the performance team at Intel is also pretty guarded. You've
> fixed the performance regressions we saw with earlier versions of SLUB
> for Netperf and Volanomark.  Our favourite online transaction processing
> benchmark is currently up about 1% against mainline+SLAB (though this is
> just reclaiming the loss that SLAB has incurred since RHEL5 split off).
> 
> What do the big system numbers look like that have you so excited about
> SLUB?

The numbers I got was just from observing some kernel compiles. The main 
win for the large systems is the cutting down of memory overhead created by 
alien caches and other structures in SLAB and the more efficient layout.

In general slab use by HPC applications is minimal. SLUB does a better 
job of staying out of the way since it does f.e. not require reaping.
