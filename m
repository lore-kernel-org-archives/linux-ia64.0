From: Paul Mackerras <paulus@samba.org>
Date: Sat, 22 Jan 2005 00:35:09 +0000
Subject: Re: Extend clear_page by an order parameter
Message-Id: <16881.40893.35593.458777@cargo.ozlabs.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0501041512450.1536@schroedinger.engr.sgi.com>
	<Pine.LNX.4.44.0501082103120.5207-100000@localhost.localdomain>
	<20050108135636.6796419a.davem@davemloft.net>
	<Pine.LNX.4.58.0501211210220.25925@schroedinger.engr.sgi.com>
	<16881.33367.660452.55933@cargo.ozlabs.ibm.com>
	<Pine.LNX.4.58.0501211545080.27045@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0501211545080.27045@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: "David S. Miller" <davem@davemloft.net>, Hugh Dickins <hugh@veritas.com>, akpm@osdl.org, linux-ia64@vger.kernel.org, torvalds@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Christoph Lameter writes:

> clear_page clears one page of the specified order.

Now you're really being confusing.  A cluster of 2^n contiguous pages
isn't one page by any normal definition.  Call it "clear_page_cluster"
or "clear_page_order" or something, but not "clear_page".

Paul.
