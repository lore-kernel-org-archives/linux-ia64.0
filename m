From: Christoph Lameter <clameter@engr.sgi.com>
Date: Tue, 16 Aug 2005 17:59:54 +0000
Subject: Re: [PATCH 3/3] - SGI SN hwperf enhancements - pcibr_bus_fixup_for_tio_busses
Message-Id: <Pine.LNX.4.62.0508161055290.7101@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0508161741540.7676@woolami.melbourne.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0508161741540.7676@woolami.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 16 Aug 2005, Mark Goodwin wrote:

> Update the SN pci device info to use the nearest node function
> to allocate driver memory on the nearest node (rather than
> defaulting to node 0).

Looks fine to me.

Note though that the default was -1 meaning "node not determined". For -1 
the default policy was used. The default policy will take memory from the 
node local to the executing thread. If the hardware initialization thread 
is running on process 0 then the use of -1 will default to node 0 
memory.
