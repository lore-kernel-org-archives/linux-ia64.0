From: Christoph Lameter <clameter@sgi.com>
Date: Tue, 22 Aug 2006 17:47:38 +0000
Subject: Re: Increase default nodes shift to 10
Message-Id: <Pine.LNX.4.64.0608221043060.24678@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0608211908270.21433@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0608211908270.21433@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hmmm... I thought this would only describe the size of the bit 
field in the page flags. But it sseem that this also determines 
MAX_NUMNODES which sizes several kernel arrays amoung them the per node 
arrays of the slab allocator. So this change would lead to more memory 
use. However, without this change generic kernel configurations will not 
work on all IA64 machines.

Also why is this set to 8 if we just have 64 processors by default?

This means the default configuration would be 256 nodes but only 64 
processors?

Could we set these limits consitently to the largest IA64 configuration to 
make sure that a generic IA64 kernel is able to run on all machines?

For that

ZONES_SHIFT needs to be 10

and

NR_CPUS needs to be 1024.
