From: Christoph Lameter <clameter@sgi.com>
Date: Tue, 12 Dec 2006 17:22:44 +0000
Subject: Re: test_and_set_bit implementation
Message-Id: <Pine.LNX.4.64.0612120921330.8557@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <457EC42C.90002@bull.net>
In-Reply-To: <457EC42C.90002@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 12 Dec 2006, Matthew Wilcox wrote:

> The original code and your rewrite both access memory twice in the loop.
> Why don't we do it with one memory reference per loop instead?

Because the the cmpxchg usually succeeds. It is rare that we have to redo 
the loop.

