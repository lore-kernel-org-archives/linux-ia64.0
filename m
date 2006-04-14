From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 14 Apr 2006 18:06:37 +0000
Subject: RE: Setup an IA64 specific reclaim distance
Message-Id: <Pine.LNX.4.64.0604141100200.20323@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0604131823410.16211@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0604131823410.16211@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 14 Apr 2006, Luck, Tony wrote:

> So node_distance is a reasonably meaningful number (providing that the
> SLIT table is a accurate representation of reality ... about which we
> are at the mercy of the f/w writers).
> 
> But I'm still trying to see why RECLAIM_DISTANCE would be different for
> ia64 systems from other architectures.  If 15 is the right number for
> ia64, why is 20 the right number for powerpc?  What if I have a 4-node
> NUMA system with a NUMA factor of 1.6?  SLIT = 

20 is a sane fallback for an architecture that potentially does not 
implement slit tables at all. REMOTE_DISTANCE is already defined to be 20
if no node_distance is defined. This means that any NUMA arch must at 
least be able to do something meaningful with numa distances 10 and 20. So 
20 is a safe value to assign to REMOTE_DISTANCE. The values in 
include/linux/topology.h are just fallback definitions.
 
> 10 16 16 16
> 16 10 16 16
> 16 16 10 16
> 16 16 16 10
> 
> Should I not use zone reclaim on this system?  But with factor=1.5
> it would be OK?

To some extend this is an arbitrary decision. But it was implemented in 
order to allow an automatic determination to switch off zone reclaim for 
low latency systems. This can be overridden by writing a value into 
/proc/sys/vm/zone_reclaim_mode.
