From: Christoph Hellwig <hch@infradead.org>
Date: Thu, 31 Mar 2005 14:32:35 +0000
Subject: Re: Fwd: [PATCH] Pageset Localization V2
Message-Id: <20050331143235.GA18058@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0503292147200.32571@server.graphe.net> <20050330111439.GA13110@infradead.org> <bab4333005033003295f487e3d@mail.gmail.com> <1112187977.9773.15.camel@kuber>
In-Reply-To: <1112187977.9773.15.camel@kuber>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: shobhit dayal <shobhit@calsoftinc.com>
Cc: hch@infradead.org, christoph@lameter.com, manfred@colorfullife.com, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mm@kvack.org, Shai Fultheim <shai@scalex86.org>

On Wed, Mar 30, 2005 at 06:36:18PM +0530, shobhit dayal wrote:
> The goal here is to replace the head of a existing list pointed to by
> 'list' with a new head pointed to by 'nlist'. 
> First there is a memcpy that copies the contents of list to nlist then
> this macro is called.
> The macro makes sure that if the old head was empty then INIT_LIST_HEAD
> the 'nlist', if not then make sure that the nodes before and after the
> head now correclty point to nlist instead of list.

Which would be much nicer done using INIT_LIST_HEAD on the new head
always and then calling list_replace (of which currently only a _rcu variant
exists).

Note to Christoph:  Just duplicating the code doesn't make it better ;-)

