From: Tejun Heo <tj@kernel.org>
Date: Tue, 27 Jul 2010 08:39:39 +0000
Subject: Re: [RFC] increase ia64 static per cpu area
Message-Id: <4C4E9B4B.1080801@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <4c4e0a40170612ea22@agluck-desktop.sc.intel.com>
In-Reply-To: <4c4e0a40170612ea22@agluck-desktop.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello,

On 07/27/2010 12:20 AM, Luck, Tony wrote:
> I've been trying to avoid this for a long time ... but per-cpu space
> has slowly been growing.  Tejun has some patches in linux-next that
> pre-reserve some space (PERCPU_DYNAMIC_EARLY_SIZE) for use before
> slab comes online ... and this pushes ia64 above the 64K current
> limit on static percpu space.

Yeah, more stuff are moving to percpu area.  I'm thinking about
increasing PERCPU_DYNAMIC_RESERVE too as it's overflowing in most
common cases now, but it's not really a bad thing tho.  Many of those
used to use NR_CPUS allocations instead so overall I don't think we're
wasting memory.

> I could probably squeeze it back under (we are only over by 512 bytes).
> But I don't think that I'll be able to squeeze it down enough to build
> a comfortable breathing space - and I don't want to keep nibbling off
> a dozen bytes here and there every time some generic code bumps us
> back over the limit.
> 
> Next available supported page size is 256K ... so we have to quadruple
> the available space - a bigger jump than I'd like. But perhaps it will
> be enough to last a few more years before it needs to be increased again.
> 
> Signed-off-by: Tony Luck <tony.luck@intel.com>

Acked-by: Tejun Heo <tj@kernel.org>

I suppose this would go through ia64 tree?

Thank you.

-- 
tejun
