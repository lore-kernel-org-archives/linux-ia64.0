From: Dean Nelson <dcn@sgi.com>
Date: Fri, 20 Aug 2004 17:17:50 +0000
Subject: Re: [PATCH] add OEM SAL call functions
Message-Id: <20040820171750.GB5126@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4126171C.mailx2731118NN@aqua.americas.sgi.com>
In-Reply-To: <4126171C.mailx2731118NN@aqua.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Aug 20, 2004 at 10:22:04AM -0500, Dean Nelson wrote:
> Add wrapper functions for SAL_CALL(), SAL_CALL_NOLOCK(), and
> SAL_CALL_REENTRANT() that allow OEM written modules to make calls
> to OEM SAL functions.
> 
> Signed-off-by: Dean Nelson <dcn@sgi.com>

Ignore this patch. I'm sending a new version with the function names
changed to something more ia64 related.

Dean
