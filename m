From: Robin Holt <holt@sgi.com>
Date: Fri, 08 Aug 2008 02:39:01 +0000
Subject: Re: [RFC] Fix early access to per-cpu variables
Message-Id: <20080808023901.GE26567@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <57C9024A16AD2D4C97DC78E552063EA3083844C8@orsmsx505.amr.corp.intel.com>
In-Reply-To: <57C9024A16AD2D4C97DC78E552063EA3083844C8@orsmsx505.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Aug 07, 2008 at 02:41:11PM -0700, Luck, Tony wrote:
> If that machine covers most of the bases ... then it should be

I have since booted it on all but two of our configs (those machines
were busy and already booked).  They are not significantly different
from the others.

> good enough.  Did you set CONFIG_PRINTK_TIME=y?  I belatedly

Yes.

Thanks,
Robin
