From: Robin Holt <holt@sgi.com>
Date: Thu, 22 Jul 2004 20:52:22 +0000
Subject: Re: Altix I/O code re-org
Message-Id: <20040722205222.GE1177@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200407221514.i6MFEVag084696@fsgi900.americas.sgi.com> <200407221357.53404.jbarnes@engr.sgi.com> <20040722192003.GA617@lnx-holt.americas.sgi.com> <20040722194050.GA797@lnx-holt.americas.sgi.com> <20040722202924.GB1177@lnx-holt.americas.sgi.com>
In-Reply-To: <20040722202924.GB1177@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Robin Holt <holt@sgi.com>
Cc: Jesse Barnes <jbarnes@engr.sgi.com>, Pat Gefre <pfg@sgi.com>, linux-ia64@vger.kernel.org, hch@infradead.org, linux-kernel@vger.kernel.org

On Thu, Jul 22, 2004 at 03:29:25PM -0500, Robin Holt wrote:
> On Thu, Jul 22, 2004 at 02:40:50PM -0500, Robin Holt wrote:
> > Pat,
> > 
> > I have a set of patches that cleanly applies against the
> > http://linux.bkbits.net/linux-2.5 bitkeeper tree using quilt.  They are
> > not available for the rest of the world yet.  Could you move them from
> > ~holt/ioif to the project's ftp directory on oss.sgi.com?
> 
> Pat, you can ignore moving those patches.  I cannot get anywhere close to
> a kernel that builds with this.  The first problem I ran into was
> a missing arch/ia64/sn/ioif/agp subdir.  I made a patch to ignore that
> subdir and am now running into missing .h files.  I am going exploring
> for a workarea to see what your tree looks like.
> 

I am out.  I need to get going for a wedding and will be gone tomorrow.

I have updated oss.sgi.com:~holt/ioif/ with the latest set of patches
I was working with.  I also fixed the permissions on those.

Thanks,
Robin
