From: David Miller <davem@davemloft.net>
Date: Mon, 24 Mar 2008 20:37:22 +0000
Subject: larger default page sizes...
Message-Id: <20080324.133722.38645342.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0803211037140.18671@schroedinger.engr.sgi.com>
	<20080321.145712.198736315.davem@davemloft.net>
	<Pine.LNX.4.64.0803241121090.3002@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0803241121090.3002@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: clameter@sgi.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, torvalds@linux-foundation.org

From: Christoph Lameter <clameter@sgi.com>
Date: Mon, 24 Mar 2008 11:27:06 -0700 (PDT)

> The move to 64k page size on IA64 is another way that this issue can
> be addressed though.

This is such a huge mistake I wish platforms such as powerpc and IA64
would not make such decisions so lightly.

The memory wastage is just rediculious.

I already see several distributions moving to 64K pages for powerpc,
so I want to nip this in the bud before this monkey-see-monkey-do
thing gets any more out of hand.
