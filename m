From: Arun Sharma <arun.sharma@intel.com>
Date: Wed, 25 Aug 2004 20:17:32 +0000
Subject: Re: Long Format VHPT patches
Message-Id: <412CF3DC.6010604@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040825023439.GA15782@cse.unsw.EDU.AU>
In-Reply-To: <20040825023439.GA15782@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 8/25/2004 10:01 AM, Jesse Barnes wrote:
> On Tuesday, August 24, 2004 7:34 pm, Ian Wienand wrote:
>> 11-lf-VHPT-kconfig.patch
> 
> Given your conclusions in the paper, would it make sense to unconditionally 
> switch to long format VHPT?  It would simplify things a little and maybe 
> avoid some trouble in the future.
> 

When the super page optimizations are implemented, long format might be a more attractive option. Without it, the increased cache footprint of the long format pte is not compensated by the benefits on the workloads we tried.

	-Arun
