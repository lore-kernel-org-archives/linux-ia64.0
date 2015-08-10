From: "Liang, Kan" <kan.liang@intel.com>
Date: Mon, 10 Aug 2015 13:23:34 +0000
Subject: RE: [BUG]: Intel uncore boot warning introduced in 4.1
Message-Id: <37D7C6CF3E00A74B8858931C1DB2F077018DF43E@SHSMSX103.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1438853676.3139.20.camel@mattleach.net>
 <87bneko0o5.fsf@mattleach.net>
 <37D7C6CF3E00A74B8858931C1DB2F077018D32C2@SHSMSX103.ccr.corp.intel.com>
 <20150807090553.GC16853@twins.programming.kicks-ass.net>
In-Reply-To: <20150807090553.GC16853@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>
Cc: Matthew Leach <matthew@mattleach.net>, Ingo Molnar <mingo@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "eranian@google.com" <eranian@google.com>, 'Andi Kleen' <ak@linux.intel.com>, 'Bjorn Helgaas' <bhelgaas@google.com>, 'Vince Weaver' <vincent.weaver@maine.edu>, 'Sonny Rao' <sonnyrao@chromium.org>


> On Thu, Aug 06, 2015 at 06:10:40PM +0000, Liang, Kan wrote:
> > The issue may be caused by uncore box initialization.
> >
> > For preventing the potential issues of uncore box initialization, I
> > once moved the uncore_box_init() out of driver initialization in
> > commit c05199e5a57a579fea1e8fa65e2b511ceb524ffc.
> >
> > However, it cause some desktop crash, because the box initialization
> > codes were moved in IPI context.
> >
> > For fixing the crash issue, we had two choice at that time.
> >  - Simply revert the codes. That's where is
> > 15c1247953e8a45232ed5a5540f291d2d0a77665 from.
> >  - Move uncore_box_init out of IPI context to uncore event
> >    init. I provided a patch for it. https://lkml.org/lkml/2015/4/28/21
> >   Stephane Eranian also verified it on his platform
> >
> > At that time, we chose first option. But it looks there is some issue
> > now. I guess we may try the second option this time.
> >
> > Matthew,
> >
> > Could you please revert
> > 15c1247953e8a45232ed5a5540f291d2d0a77665
> > and apply the patch https://lkml.org/lkml/2015/4/26/294?
> > See if it works?
> 
> That patch is wrong though; how can even publish a PMU which is not
> initialized?

It's initialized but not in the driver initialization.
We once encountered boot crashes which caused by uncore
driver who trying to access non-existing boxes. Also this uncore
boot warning.
So I think it's better to move the box init code out of driver
initialization to prevent such potential boot failures.
Uncore event init should be a good place to do box init.
Only when the box is not initialized and user tries to use
uncore event, we do box initialization.

Thanks,
Kan
