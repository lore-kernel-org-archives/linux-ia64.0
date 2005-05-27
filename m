From: Jesse Barnes <jesse.barnes@intel.com>
Date: Fri, 27 May 2005 16:13:06 +0000
Subject: Re: ia64 sched-domains initialisation
Message-Id: <200505270913.06854.jesse.barnes@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42974381.9080000@bull.net>
In-Reply-To: <42974381.9080000@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Friday, May 27, 2005 8:57 am, Xavier Bru wrote:
> An other alternative is using the node_distance() that comes from the
> SLIT to build the sched domains instead of using
> SD_NODES_PER_DOMAIN on the platform.

This option seems like the way to go.  The size is far from optimally 
tuned as well, benchmarking is needed (unless we want boot time 
heuristics to determine the sched domain layout).

> The following patch sets SD_NODES_PER_DOMAIN as a config/boot
> parameter, and when the value is 0 uses the node_distance to build
> the sched domains.

Maybe you could make that the default behavior?

Jesse
