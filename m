From: Christoph Hellwig <hch@infradead.org>
Date: Fri, 17 Oct 2003 17:47:51 +0000
Subject: Re: [patch] xbow.c kmalloc fixes
Message-Id: <marc-linux-ia64-106641334730093@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106641220628729@msgid-missing>
In-Reply-To: <marc-linux-ia64-106641220628729@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Oct 17, 2003 at 10:31:27AM -0700, David Mosberger wrote:
> So what should be done about these SN2 cleanups?  I don't want to
> accept dozens of small "fixes" (which really are mostly cleanups) as
> that would defeat the idea of the code-fixes-only decree.  On the
> other hand, I really would like to see the SN2 code cleaned up so we actually
> have a sane base to do bug fixes on top of.

What about letting the SGI folks creeate a sn-cleanups-2.6 BK tree and
let them deal with Linus themselves with your below blanket approval?

