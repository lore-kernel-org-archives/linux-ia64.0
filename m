From: "Seth, Rohit" <rohit.seth@intel.com>
Date: Thu, 20 Jan 2005 19:00:42 +0000
Subject: RE: [patch] ia64: fix potential NaT bit error for sys_pipe().
Message-Id: <01EF044AAEE12F4BAAD955CB7506494302DFEC10@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16878.2168.388519.26567@napali.hpl.hp.com>
In-Reply-To: <16878.2168.388519.26567@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger <mailto:davidm@napali.hpl.hp.com> wrote on Thursday,
January 20, 2005 9:53 AM:

> Tony,
> 
> Please disregard the patch named in $SUBJECT.  It appears to be
> breaking light-weight syscalls.  That's rather odd, but since Rohit
> has some better ideas on how to fix this issue, I'd rather drop this
> patch for the time being (the root problem is still there and IMHO,
> needs to be fixed urgently).
> 
> 	--david

I will send out the first rev of patch today to address the
functionality issue.  This patch will not worry about exporting the NAT
bits in r8-r11 to user.  So, the ld.fills will be replaced by simple ld.


Though, as per the disussions with David, there is scope of further
optimization in the way we are saving/restoring r8-r11 in this code.
This will probably need little more analysis to ensure best
placement/scheduling of new code. Will send that later...

Thanks, 
-rohit
