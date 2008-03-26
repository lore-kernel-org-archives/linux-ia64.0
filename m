From: David Miller <davem@davemloft.net>
Date: Wed, 26 Mar 2008 00:39:28 +0000
Subject: Re: larger default page sizes...
Message-Id: <20080325.173928.67585726.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080325.162244.61337214.davem@davemloft.net>
	<87tziu5q37.wl%peter@chubb.wattle.id.au>
	<ed5aea430803251734u70f199w10951bc4f0db6262@mail.gmail.com>
In-Reply-To: <ed5aea430803251734u70f199w10951bc4f0db6262@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dmosberger@gmail.com
Cc: peterc@gelato.unsw.edu.au, clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, torvalds@linux-foundation.org, ianw@gelato.unsw.edu.au

From: "David Mosberger-Tang" <dmosberger@gmail.com>
Date: Tue, 25 Mar 2008 18:34:13 -0600

> Why not just repeat the PTEs for super-pages?

This is basically how we implement hugepages in the page
tables on sparc64.
