From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 14 Apr 2006 17:43:14 +0000
Subject: RE: Setup an IA64 specific reclaim distance
Message-Id: <Pine.LNX.4.64.0604141041310.18724@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0604131823410.16211@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0604131823410.16211@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 14 Apr 2006, Luck, Tony wrote:

> Ah, but looking at the code, I think I was mistaken ... it seems
> to only know about distances between scheduler domains ... which
> may or may not match with all the node information.  But it might
> still be worth looking at to see whether it can be used, or can
> be easily extended to be used.  A measured value is often better
> than a static define that doesn't apply to all systems.

RECLAIM_DISTANCE is compared against the largest node_distance() in the 
system in order to make the decision if zone_reclaim should be enabled for 
a system.

node_distance() uses the SLIT talbe and is a dynamic value provided by 
each system.
