From: David Miller <davem@davemloft.net>
Date: Wed, 26 Mar 2008 00:31:46 +0000
Subject: Re: larger default page sizes...
Message-Id: <20080325.173146.238342309.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <87tziu5q37.wl%peter@chubb.wattle.id.au>
	<20080325.164927.249210766.davem@davemloft.net>
	<87od925o15.wl%peter@chubb.wattle.id.au>
In-Reply-To: <87od925o15.wl%peter@chubb.wattle.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: peterc@gelato.unsw.edu.au
Cc: clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, torvalds@linux-foundation.org, ianw@gelato.unsw.edu.au

From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Wed, 26 Mar 2008 11:25:58 +1100

> That depends on the access pattern.

Absolutely.

FWIW, I bet it helps enormously for gcc which, even for
small compiles, swims around chaotically in an 8MB pool
of GC'd memory.
