From: Christoph Hellwig <hch@lst.de>
Date: Wed, 15 Oct 2003 13:40:49 +0000
Subject: Re: IA64 ino_t incorrectly sized?
Message-Id: <marc-linux-ia64-106622533612093@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106378281914262@msgid-missing>
In-Reply-To: <marc-linux-ia64-106378281914262@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Oct 15, 2003 at 02:29:21PM +0100, Matthew Wilcox wrote:
> On Wed, Oct 15, 2003 at 02:54:53PM +0200, Christoph Hellwig wrote:
> > On Wed, Oct 15, 2003 at 11:25:04AM +1000, Nathan Scott wrote:
> > > I'd appreciate any suggestions about a cleaner way to do the
> > > common types.h and nfsd/syscall.h header changes.
> > 
> > First question:  What about other LP64 arches besides IA64.  IMHO
> > having differen't ino_t on different LP64 arches is a rather bad idea.
> 
> All architectures typedef __kernel_ino_t to unsigned long except alpha,
> ia64 and s390x.  I guess ia64 just copied the wrong architecture at
> the beginning.

So we should probably change introduce __HAVE_BROKEN_INO_T for alpha
and s390x?  Even better those should get new versions of the relevant
syscalls, I expect at least s390x to want them one day.

