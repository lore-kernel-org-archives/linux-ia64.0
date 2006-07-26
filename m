From: Zou Nan hai <nanhai.zou@intel.com>
Date: Wed, 26 Jul 2006 21:08:44 +0000
Subject: RE: [Patch] Don't alloc empty frame in ia64_switch_mode_phys
Message-Id: <1153948124.3286.76.camel@linux-znh>
List-Id: <linux-ia64.vger.kernel.org>
References: <1153870600.3286.72.camel@linux-znh>
In-Reply-To: <1153870600.3286.72.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2006-07-26 at 23:33, Chen, Kenneth W wrote:
> Zou Nan hai wrote on Tuesday, July 25, 2006 4:37 PM
> > I think ia64_switch_mode_phys and ia64_switch_mode_virt 
> > does not need to alloc an empty frame. 
> > An empty frame is required by loadrs but flushrs 
> > does not need that.
> 
> This patch would make your previous "Do not assume output registers
> be reservered" unnecessary, isn't it?  It will automatically solve
> the problem you are trying to fix in previous patch.
> 
  Yes, any individual of the 2 patches will fix the issue. 
  However I still like to fix the "assume output registers to be
preserved issue" in pal.S, because that dose not follow software runtime
convention.

  Zou Nan hai
