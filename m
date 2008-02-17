From: Christoph Hellwig <hch@infradead.org>
Date: Sun, 17 Feb 2008 13:13:14 +0000
Subject: Re: git-nfsd on ia64
Message-Id: <20080217131314.GA12056@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080215223943.d12b8eb5.akpm@linux-foundation.org>
In-Reply-To: <20080215223943.d12b8eb5.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, Feb 16, 2008 at 08:27:06PM -0500, J. Bruce Fields wrote:
> > This should have been done in the first place, IMO.  Avoid header file
> > dependencies, faster compile, avoid crap like the above.
> 
> OK.  So as a general rule, we should skip the include any time when a
> few structure declarations would suffice?

Yes.  Unessecary includes should always be avoided, and forward
declarations are a nice way to avoid includes.

> Hm.  It also seems wrong that sys_ia32.c would need to include so many
> nfsd/sunrpc headers.  It looks like that should be easy to fix with a
> better organization of the nfsd headers--I'll do that, assuming it's
> considered worthwhile....

Why does it need to include either of these at all?  There's nothing
nfs-specific in that file.
