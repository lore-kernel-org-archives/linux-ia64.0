From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 05 Oct 2004 15:44:48 +0000
Subject: Re: [patch 0/5 salinfo-0.6] summary
Message-Id: <200410050944.48565.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <11145.1096870990@kao2.melbourne.sgi.com>
In-Reply-To: <11145.1096870990@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Monday 04 October 2004 7:42 pm, Keith Owens wrote:
> On Mon, 4 Oct 2004 10:02:18 -0600, 
> Bjorn Helgaas <bjorn.helgaas@hp.com> wrote:
> >By the way, I hear grumbling from neighboring cubes about
> >the colons in the log file names, because it makes it hard
> >to move the files to Windows (HP's log analysis tools are
> >Windows-based).
> >
> >How much of a hassle would it be if we changed the colons
> >to underscores or something?
> 
> Windows - yuck!

Yeah, I know :-(  But if we can make interoperability easier
without screwing up existing users, it seems reasonable.

> Do you want to add this to 0.6 or bump the version to 0.7?

I made a 0.7 with that patch.  Thanks!

ftp://ftp.kernel.org/pub/linux/kernel/people/helgaas/salinfo-0.7.tar.gz
