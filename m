From: Dean Nelson <dcn@sgi.com>
Date: Tue, 25 Mar 2008 20:05:17 +0000
Subject: Re: [Patch 5/5] run drivers/misc/xp through scripts/checkpatch.pl
Message-Id: <20080325200517.GA4446@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080325192524.343385569@attica.americas.sgi.com> <20080325192558.959273025@attica.americas.sgi.com>
In-Reply-To: <20080325192558.959273025@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: apw@shadowen.org, rdunlap@xenotime.net, jschopp@austin.ibm.com
Cc: jes@sgi.com, linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org

On Tue, Mar 25, 2008 at 02:25:29PM -0500, dcn@sgi.com wrote:
> 
> Addressed issues raised by scripts/checkpatch.pl. Removed unnecessary curly
> braces.  Eliminated uses of volatiles and use of kernel_thread() and
> daemonize().
> 
> Signed-off-by: Dean Nelson <dcn@sgi.com>
> 

Forgot to mention that scripts/checkpatch.pl gave 15 false positives of
the following type against drivers/misc/xp/xp_main.c.

> WARNING: EXPORT_SYMBOL(foo); should immediately follow its function/variable
> #48: FILE: misc/xp/xp_main.c:48:
> +EXPORT_SYMBOL_GPL(xp_remote_memcpy);

The fact is that the EXPORT_SYMBOL(xp_remote_memcpy) does immediately follow
the function/variable as follows.

enum xp_retval (*xp_remote_memcpy) (void *dst, const void *src, size_t len);
EXPORT_SYMBOL_GPL(xp_remote_memcpy);

