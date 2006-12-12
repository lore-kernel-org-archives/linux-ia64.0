From: Matthew Wilcox <matthew@wil.cx>
Date: Tue, 12 Dec 2006 18:07:44 +0000
Subject: Re: test_and_set_bit implementation
Message-Id: <20061212180744.GJ21070@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <457EC42C.90002@bull.net>
In-Reply-To: <457EC42C.90002@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Dec 12, 2006 at 09:22:44AM -0800, Christoph Lameter wrote:
> On Tue, 12 Dec 2006, Matthew Wilcox wrote:
> 
> > The original code and your rewrite both access memory twice in the loop.
> > Why don't we do it with one memory reference per loop instead?
> 
> Because the the cmpxchg usually succeeds. It is rare that we have to redo 
> the loop.

Even if the loop executes exactly once, we still win by an ld4 vs an
ld4.acq.  It can't be less expensive to do an ld4.acq than it is to do
an ld4.
