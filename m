From: Matthew Wilcox <willy@debian.org>
Date: Wed, 15 Oct 2003 13:29:21 +0000
Subject: Re: IA64 ino_t incorrectly sized?
Message-Id: <marc-linux-ia64-106622473311421@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106378281914262@msgid-missing>
In-Reply-To: <marc-linux-ia64-106378281914262@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Oct 15, 2003 at 02:54:53PM +0200, Christoph Hellwig wrote:
> On Wed, Oct 15, 2003 at 11:25:04AM +1000, Nathan Scott wrote:
> > I'd appreciate any suggestions about a cleaner way to do the
> > common types.h and nfsd/syscall.h header changes.
> 
> First question:  What about other LP64 arches besides IA64.  IMHO
> having differen't ino_t on different LP64 arches is a rather bad idea.

All architectures typedef __kernel_ino_t to unsigned long except alpha,
ia64 and s390x.  I guess ia64 just copied the wrong architecture at
the beginning.

> AQnd if we go the ino_t is unsigned long route for all 64bit arches
> the ifdefs would also magically disappear..

Sounds like a good plan.

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
