From: Christoph Lameter <christoph@lameter.com>
Date: Thu, 26 Aug 2004 20:19:49 +0000
Subject: Re: Long Format VHPT patches
Message-Id: <Pine.LNX.4.58.0408261311490.1674@server.home>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040825023439.GA15782@cse.unsw.EDU.AU>
In-Reply-To: <20040825023439.GA15782@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

One issue that bothers me is that it is no longer possible to swap pte,
pmd and pgd entries via cmpxchg. My page fault scalability patches are based
on that ability. The Itanium can only do a cmpxchg with a 64 bit value.
The long VHPT entries are 32 bytes long.

IMHO the cmpxchg is unavoidable if we want to increase the scalability of
page fault handling because it offers the shortest and most efficient way
to do synchronize updates to the page tables.

The Intel developers manual documents a way to invalidate a long VHPT
entry while updating it. A special pte_cmpxchg would be needed that
invalidates a VHPT via an atomic operation to set the ti bit, then
does the cmpxchg stuff and then validates the VHPT again. The
page fault handler would have to be modified to redo the fault if the ti
bit is set. However, this is may be significantly than a single cmpxchg.
