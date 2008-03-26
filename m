From: Dean Nelson <dcn@sgi.com>
Date: Wed, 26 Mar 2008 16:58:39 +0000
Subject: Re: [Patch 5/5] run drivers/misc/xp through scripts/checkpatch.pl
Message-Id: <20080326165839.GG20663@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080325192524.343385569@attica.americas.sgi.com> <20080325192558.959273025@attica.americas.sgi.com> <20080325200517.GA4446@sgi.com> <20080326100336.GE22584@shadowen.org>
In-Reply-To: <20080326100336.GE22584@shadowen.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andy Whitcroft <apw@shadowen.org>
Cc: rdunlap@xenotime.net, jschopp@austin.ibm.com, jes@sgi.com, linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org

On Wed, Mar 26, 2008 at 10:03:36AM +0000, Andy Whitcroft wrote:
> On Tue, Mar 25, 2008 at 03:05:17PM -0500, Dean Nelson wrote:
> 
> Gah, who ever came up with that syntax.  Yep, thats a falsie.  Should be
> fixed in the latest version:
> 
>   http://www.kernel.org/pub/linux/kernel/people/apw/checkpatch/checkpatch.pl-next
> 
> Thanks for the report.

You're welcome and thanks for the quick fix to checkpatch.pl.
I used the new version and it fixed the problem except for ones that were of
the following form:

enum xp_retval (*xp_set_amo_with_interrupt) (u64 *amo_va, int op, u64 operand,
                                             int remote, int nasid,
                                             int phys_cpuid, int vector);
EXPORT_SYMBOL_GPL(xp_set_amo_with_interrupt);

which still generated the false positive:

WARNING: EXPORT_SYMBOL(foo); should immediately follow its function/variable
#70: FILE: misc/xp/xp_main.c:70:
+EXPORT_SYMBOL_GPL(xp_set_amo_with_interrupt);

Thanks,
Dean
