From: Matthew Wilcox <matthew@wil.cx>
Date: Fri, 02 Sep 2005 18:24:53 +0000
Subject: Re: [PATCH 2.6.13] IOCHK interface for I/O error handling/detecting (for ia64)
Message-Id: <20050902182453.GB28254@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <431694DB.90400@jp.fujitsu.com> <20050901172917.I10072@chenjesu.americas.sgi.com>
In-Reply-To: <20050901172917.I10072@chenjesu.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Brent Casavant <bcasavan@sgi.com>
Cc: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, linux-ia64@vger.kernel.org, Linux Kernel list <linux-kernel@vger.kernel.org>

On Thu, Sep 01, 2005 at 05:45:54PM -0500, Brent Casavant wrote:
> I am extremely concerned about the performance implications of this
> implementation.  These changes have several deleterious effects on I/O
> performance.

I agree.  I think the iochk patches should be abandoned and the feature
reimplemented on top of the asynchronous PCI error notification patches
from Linas Vepstas.
