From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 26 Jan 2005 21:30:34 +0000
Subject: Re: syscall exit path optimization
Message-Id: <16888.3066.620857.773456@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501262102.j0QL2Qg28166@unix-os.sc.intel.com>
In-Reply-To: <200501262102.j0QL2Qg28166@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I like the patch (it's quite clever!), except it would be nice if we
could avoid the p8/p9 dependencies.  Couldn't you restore r8/r10 after
.work_pending is done in if pLvSys is TRUE?  That way, .work_processed
would simply preserve (save _and_ restore) r8/r10.  My comments are
based on reading the diff only, though, so perhaps I'm missing
something.

	--david
