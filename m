From: Christoph Lameter <christoph@lameter.com>
Date: Thu, 31 Mar 2005 15:36:07 +0000
Subject: Re: Fwd: [PATCH] Pageset Localization V2
Message-Id: <Pine.LNX.4.58.0503310735150.6034@server.graphe.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0503292147200.32571@server.graphe.net>
 <20050330111439.GA13110@infradead.org> <bab4333005033003295f487e3d@mail.gmail.com>
 <1112187977.9773.15.camel@kuber> <20050331143235.GA18058@infradead.org>
 <20050331144740.GB21986@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20050331144740.GB21986@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <matthew@wil.cx>
Cc: Christoph Hellwig <hch@infradead.org>, shobhit dayal <shobhit@calsoftinc.com>, manfred@colorfullife.com, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mm@kvack.org, Shai Fultheim <shai@scalex86.org>

On Thu, 31 Mar 2005, Matthew Wilcox wrote:

> On Thu, Mar 31, 2005 at 03:32:35PM +0100, Christoph Hellwig wrote:
> > Which would be much nicer done using INIT_LIST_HEAD on the new head
> > always and then calling list_replace (of which currently only a _rcu variant
> > exists).
>
> INIT_LIST_HEAD followed by list_splice() should do the trick, I think.
> BTW, is it a problem that the list head which the list was copied from
> still points into the list?

The code runs during startup and the section containing the old pointers
is discarded at the end of the boot process.
