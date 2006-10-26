From: Russ Anderson <rja@sgi.com>
Date: Thu, 26 Oct 2006 16:44:51 +0000
Subject: Re: [patch] Mixed Madison and Montecito system support
Message-Id: <200610261644.k9QGipAf21995445@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <20061025164253.A21790@unix-os.sc.intel.com> from "Siddha, Suresh B" at Oct 25, 2006 04:42:53 PM
References: <200610130325.k9D3PwIo17962445@clink.americas.sgi.com>
In-Reply-To: <200610130325.k9D3PwIo17962445@clink.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Siddha, Suresh B" <suresh.b.siddha@intel.com>
Cc: Russ Anderson <rja@sgi.com>, Luck Tony <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Siddha, Suresh B wrote:
> 
> I added it so that these entries will not confuse users of a non-smt/mc
> systems. But mixed type of processors and cpu hotplug really complicates the
> things..

Yes, it does.  :-)
 
> May be a check of something like "is this platform capable of
> supporting any multi-core/multi-threaded processor package?" helps..
> 
> As there is no well defined mechanism to find out that and for simplicity
> reasons, we should probably go with Tony's suggestion.
> 
> Russ I can post a patch, removing both smt_capable() and mc_capable()
> checks.

Yes, please do.

> Today this sysfs variable is not documented. But when it happens, we
> need to clearly document that these variables have no meaning when
> the system doesn't have cpus with threads/cores.


-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
