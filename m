From: Christoph Hellwig <hch@infradead.org>
Date: Sun, 17 Feb 2008 13:21:32 +0000
Subject: Re: git-nfsd on ia64
Message-Id: <20080217132132.GA5777@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080215223943.d12b8eb5.akpm@linux-foundation.org>
In-Reply-To: <20080215223943.d12b8eb5.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, Feb 16, 2008 at 05:18:01PM -0800, Andrew Morton wrote:
> On Sat, 16 Feb 2008 20:12:06 -0500 "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > > 
> > > .config:3397:warning: trying to assign nonexistent symbol NFSD_TCP
> > 
> > Should I be removing all references to NFSD_TCP in the patch that
> > removes NFSD_TCP?  That would mean touching 90 config files under arch.
> 
> Nope.  They will slowly disappear over time as maintainers refresh their
> defconfigs.

That implies maintainers actually maintaining it.  When did we get the
last real update (nto just removeing dead options) to the 32bit x86
defconfig?
