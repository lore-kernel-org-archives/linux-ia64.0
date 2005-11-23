From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 23 Nov 2005 15:07:49 +0000
Subject: RE: [Xen-devel] __ia64__ ifdef in xmalloc.c: "Fix ar.unat handling forfast paths"
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F05080A09@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <571ACEFD467F7749BC50E0A98C17CDD802C069CF@pdsmsx403>
In-Reply-To: <571ACEFD467F7749BC50E0A98C17CDD802C069CF@pdsmsx403>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Keir Fraser <Keir.Fraser@cl.cam.ac.uk>, "Tian, Kevin" <kevin.tian@intel.com>
Cc: djm@kirby.fc.hp.com, Rusty Russell <rusty@rustcorp.com.au>, linux-ia64@vger.kernel.org, David Mosberger-Tang <David.Mosberger@acm.org>, Tony Breeds <tony@bakeyournoodle.com>, Xen Mailing List <xen-devel@lists.xensource.com>

>It's not hard to support arbitrary alignment, at the cost of burning 
>some space. We should probably do that.

The "we" in that last sentence is the Xen team ... referring
to making fixes to xmalloc?

-Tony
