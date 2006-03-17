From: Carsten Otte <cotte@de.ibm.com>
Date: Fri, 17 Mar 2006 12:29:48 +0000
Subject: Re: [patch] mspec - special memory driver and do_no_pfn handler
Message-Id: <441AABBC.1060809@de.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq0k6auuy5n.fsf@jaguar.mkp.net> <20060316163728.06f49c00.akpm@osdl.org> <Pine.LNX.4.64.0603161659210.3618@g5.osdl.org>
In-Reply-To: <Pine.LNX.4.64.0603161659210.3618@g5.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@osdl.org>
Cc: Andrew Morton <akpm@osdl.org>, Jes Sorensen <jes@sgi.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, hch@lst.de, Hugh Dickins <hugh@veritas.com>, Arnd Bergmann <arnd@arndb.de>

Linus Torvalds wrote:
> Quite frankly, I don't think nopfn() is a good interface. It's only usable 
> for one single thing, so trying to claim that it's a generic VM op is 
> really not valid. If (and that's a big if) we need this interface, we 
> should just do it inside mm/memory.c instead of playing games as if it was 
> generic.
Execute in place would be the second single thing we'll need it for. Also,
I remember a statement from Anrd that it has value for SPUfs on Cell which
does count as singe thing #3. With three single things at hand, I believe
there is some sense in makeing it "a generic thing".

Carsten
