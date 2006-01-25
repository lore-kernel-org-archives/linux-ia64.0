From: "Bryan O'Sullivan" <bos@pathscale.com>
Date: Wed, 25 Jan 2006 20:33:32 +0000
Subject: RE: [perfmon] Re: quick overview of the perfmon2 interface
Message-Id: <1138221212.15295.35.camel@serpentine.pathscale.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <3C87FFF91369A242B9C9147F8BD0908A02C6955C@cacexc04.americas.cpqcorp.net>
In-Reply-To: <3C87FFF91369A242B9C9147F8BD0908A02C6955C@cacexc04.americas.cpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Truong, Dan" <dan.truong@hp.com>
Cc: Andrew Morton <akpm@osdl.org>, "Eranian, Stephane" <stephane.eranian@hp.com>, perfmon@napali.hpl.hp.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, perfctr-devel@lists.sourceforge.net

On Fri, 2006-01-20 at 10:37 -0800, Truong, Dan wrote:
> Would you want Stephane to guard the extended
> functionalities with tunables or something to
> Disable their regular use and herd enterprise
> Tools into a standard mold... yet allow R&D to
> Move on by enabling the extentions?

I'd prefer to see all of the extended stuff left out entirely for now.
The mainline kernel has no PMU support for any popular architecture,
even though external patches have existed in stable form for years.
Filling that gap ought to be the priority; the interface can be extended
when actual users of new features show up and ask for them.

> It would restrict the R&D mindset, and new ideas.
> The field hasn't grown yet to a stable mature form.

The place for flailing around with uncooked ideas is arguably not the
mainline kernel.

> Flexibility is/was needed because:
> - Tools need to port to Perfmon with min cost.
> - Ability to support novel R&D ideas.
> - Ability to support growth beyond just PMU data
> - Allows early data aggregation
> - Allow OS data correlated to PMU

Speculatively adding complicated and unused interfaces to the kernel in
the hope that some wild-eyed visionary might eventually up and use them
helps nobody.

	<b

