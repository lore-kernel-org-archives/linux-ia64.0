From: "Truong, Dan" <dan.truong@hp.com>
Date: Fri, 20 Jan 2006 18:37:42 +0000
Subject: RE: [perfmon] Re: quick overview of the perfmon2 interface
Message-Id: <3C87FFF91369A242B9C9147F8BD0908A02C6955C@cacexc04.americas.cpqcorp.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: "Eranian, Stephane" <stephane.eranian@hp.com>, perfmon@napali.hpl.hp.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, perfctr-devel@lists.sourceforge.net

Would you want Stephane to guard the extended
functionalities with tunables or something to
Disable their regular use and herd enterprise
Tools into a standard mold... yet allow R&D to
Move on by enabling the extentions?



Just crippling flexibility/cutting functionality
is like removing words out of a dictionary to
prevent people from thinking different.

It would restrict the R&D mindset, and new ideas.
The field hasn't grown yet to a stable mature form.
It is just beginning: profiling, monitoring, tuning,
compilers, JIT...

Flexibility is/was needed because:
- Tools need to port to Perfmon with min cost.
- Ability to support novel R&D ideas.
- Ability to support growth beyond just PMU data
- Allows early data aggregation
- Allow OS data correlated to PMU

What standardization adds:
- Coordinated access to PMU rssources from all tools
- All tools/formats etc all plug into the same OS framework.
- The interface gets ported across multiple platforms.
- The functionality is rich for all (fast data transfers,
  multiplexing, system vs thead, etc.)

Dan-

> -----Original Message-----
> From: perfmon-bounces@napali.hpl.hp.com [mailto:perfmon-
> bounces@napali.hpl.hp.com] On Behalf Of Andrew Morton
> Sent: Thursday, December 22, 2005 5:47 AM
> To: Truong, Dan
> Cc: Eranian, Stephane; perfmon@napali.hpl.hp.com; linux-
> ia64@vger.kernel.org; linux-kernel@vger.kernel.org; perfctr-
> devel@lists.sourceforge.net
> Subject: Re: [perfmon] Re: quick overview of the perfmon2 interface
> 
> "Truong, Dan" <dan.truong@hp.com> wrote:
> >
> > The PMU is becoming a standard commodity. Once Perfmon is
> > "the" Linux interface, all the tools can align on it and
> > coexist, push their R&D forward, and more importantly become
> > fully productized for businesses usage.
> >
> 
> The apparently-extreme flexibility of the perfmon interfaces would
tend to
> militate against that, actually.  It'd become better productised if it
had
> one interface and stuck to it.
> 
> (I haven't processed Stephane's reply yet - will get there)
> 
> _______________________________________________
> perfmon mailing list
> perfmon@linux.hpl.hp.com
> http://www.hpl.hp.com/hosted/linux/mail-archives/perfmon/
