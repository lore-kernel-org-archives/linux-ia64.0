From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 24 Mar 2004 15:53:00 +0000
Subject: Re: 2.4.25 + 040218.diff OOPS
Message-Id: <200403240853.00329.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040320115002.GF21377@louise.pinerecords.com>
In-Reply-To: <20040320115002.GF21377@louise.pinerecords.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday 24 March 2004 3:54 am, Tomas Szepe wrote:
> On Mar-23 2004, Tue, 10:12 -0700
> Bjorn Helgaas <bjorn.helgaas@hp.com> wrote:
> 
> > Can you look up these IPs by hand, since ksymoops doesn't work?
> > (I always use gdb: "info line *0xe00000000447cfe2").
> 
> Ok, I'll try to when (if) the OOPS reappears.

If you still have the kernel image that was running when you saw the
oops, you can still run gdb on that image.
