From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 02 Mar 2005 19:33:29 +0000
Subject: Re: [patch - 2.6.11-rc5-mm1] genalloc - general purpose allocator
Message-Id: <16934.5385.841758.628631@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16934.4191.474769.320391@jaguar.mkp.net>
In-Reply-To: <16934.4191.474769.320391@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jes Sorensen <jes@trained-monkey.org>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

At the risk of asking the obvious: what's preventing genalloc to be
implemented in terms of mempool?

	--david
