From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Wed, 23 Jun 2004 10:47:56 +0000
Subject: Re: Is vfat fs case sensitive in 2.6.7?
Message-Id: <200406230648.00480.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040622224302.GA953@lucon.org>
In-Reply-To: <20040622224302.GA953@lucon.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday, June 23, 2004 2:21 am, Christoph Hellwig wrote:
> On Tue, Jun 22, 2004 at 11:14:01PM -0700, H. J. Lu wrote:
> > I have
> >
> > CONFIG_NLS_DEFAULT="utf8"
> >
> > in .config. Does it make a difference?
>
> Yes, check recent lkml archives.

This should be fixed as of -bk4 or so.  I submitted a patch to the FAT 
maintainer to prevent utf8 from being used for FAT filesystems, since it 
doesn't allow for FAT semantics.

Jesse
