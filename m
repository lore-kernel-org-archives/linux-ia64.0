From: Andi Kleen <ak@suse.de>
Date: Fri, 26 Mar 2004 07:10:18 +0000
Subject: Re: Migrate pages from a ccNUMA node to another
Message-Id: <20040326081018.0f34e281.ak@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <4063F188.66DB690A@nospam.org>
	<20040326103959.GB14360@lnx-holt>
In-Reply-To: <20040326103959.GB14360@lnx-holt>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Robin Holt <holt@sgi.com>
Cc: Zoltan.Menyhart_AT_bull.net@nospam.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, 26 Mar 2004 04:39:59 -0600
Robin Holt <holt@sgi.com> wrote:

> One thing that would probably help considerably, in addition to the
> syscall you seem to be proposing, would be an addition to the
> task_struct.  The new field would specify which node to attempt
> allocations on.  Before doing a fork, the parent would do a
> syscall to set this field to the node the child will target.  It
> would then call fork.  The PGDs et al and associated memory, including
> the task struct and pages would end up being allocated based upon
> that numa node's allocation preference.

You just described the process policy of NUMA API.

-Andi
