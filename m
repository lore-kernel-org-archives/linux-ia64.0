From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 14 Apr 2006 16:44:58 +0000
Subject: RE: Setup an IA64 specific reclaim distance
Message-Id: <Pine.LNX.4.64.0604140943130.18453@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0604131823410.16211@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0604131823410.16211@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 14 Apr 2006, Luck, Tony wrote:

> > We found that on motherboard latencies are typically 1 to 1.4 of local memory
> > access speed whereas multinode systems which benefit from zone reclaim have
> > usually more than 1.5 times the latency of a local access.
> > 
> > Set the reclaim distance for IA64 to 1.5 times.
> 
> Does this really apply just to ia64 systems?  Or is the "20" value in
> topology.h just wrong?

The value in topology.h is the same as the REMOTE_DISTANCE. I think we 
better leave these as fallbacks for systems that do not implement 
node_distance().

> Is the right value for this any any way related to the "migration_cost"
> that we spend many seconds of boot time computing?

I am not familiar with that. Does the migration_cost take the 
SLIT node distances into consideration?

