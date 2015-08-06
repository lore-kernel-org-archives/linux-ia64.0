From: "Liang, Kan" <kan.liang@intel.com>
Date: Thu, 06 Aug 2015 18:10:40 +0000
Subject: RE: [BUG]: Intel uncore boot warning introduced in 4.1
Message-Id: <37D7C6CF3E00A74B8858931C1DB2F077018D32C2@SHSMSX103.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1438853676.3139.20.camel@mattleach.net>
 <87bneko0o5.fsf@mattleach.net>
In-Reply-To: <87bneko0o5.fsf@mattleach.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Leach <matthew@mattleach.net>, Ingo Molnar <mingo@kernel.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "eranian@google.com" <eranian@google.com>, 'Andi Kleen' <ak@linux.intel.com>, 'Bjorn Helgaas' <bhelgaas@google.com>, 'Vince Weaver' <vincent.weaver@maine.edu>, 'Peter Zijlstra' <peterz@infradead.org>, 'Sonny Rao' <sonnyrao@chromium.org>


> 
> Hi Ingo,
> 
> Matthew Leach <matthew@mattleach.net> writes:
> 
> [...]
> 
> > I've bisected the kernel and found that commit [2] seems to introduce
> > the warning message.  I have checked on a v4.2-rc5 kernel and the
> > warning message is still there.
> 
> [...]
> 
> > [2]: 8cf1a3de97804b047973dd44cfacdc1930da8403
> 
> Apologies, I got it wrong.  The commit that is causing the issue is [1].
> If I revert it, the warning goes away.  I'm also testing to see if this is the
> cause of the random freezing that occurs (which I can confirm is also
> happening with v4.2-rc5).
> 
> [1]: 15c1247953e8a45232ed5a5540f291d2d0a77665
> 

The issue may be caused by uncore box initialization.

For preventing the potential issues of uncore box initialization, I once
moved the uncore_box_init() out of driver initialization in commit
c05199e5a57a579fea1e8fa65e2b511ceb524ffc.

However, it cause some desktop crash, because the box initialization
codes were moved in IPI context.
 
For fixing the crash issue, we had two choice at that time.
 - Simply revert the codes. That's where is
15c1247953e8a45232ed5a5540f291d2d0a77665 from.
 - Move uncore_box_init out of IPI context to uncore event
   init. I provided a patch for it. https://lkml.org/lkml/2015/4/28/21
  Stephane Eranian also verified it on his platform

At that time, we chose first option. But it looks there is some
issue now. I guess we may try the second option this time.

Matthew,

Could you please revert
15c1247953e8a45232ed5a5540f291d2d0a77665
and apply the patch https://lkml.org/lkml/2015/4/26/294?
See if it works?


Thanks,
Kan


