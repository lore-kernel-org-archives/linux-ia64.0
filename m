From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 08 Oct 2003 22:54:07 +0000
Subject: Re: user-space unaligned accesses
Message-Id: <marc-linux-ia64-106565367106363@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106562414203331@msgid-missing>
In-Reply-To: <marc-linux-ia64-106562414203331@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday 08 October 2003 3:46 pm, Grant Grundler wrote:
> On Wed, Oct 08, 2003 at 08:42:00AM -0600, Bjorn Helgaas wrote:
> > ...
> > The ia64 architecture does a tty_write
> > on a userspace unaligned access. Not only is this extremenly annoying,
> > it's also very broken since the tty may well be suspended etc etc.
> > Doing a printk on such an access by default is very broken already,
> > lets not make it worse
> 
> This was beat to death on linux-ia64 already where davidm and davem
> decided to disagree on the utility of printing unaligned accesses
> to the tty.

I thought that discussion was mainly about messages printed by the
kernel using printk.  The Red Hat concern was specifically about
writing to the user tty.

> davidm wrote:
> | At the moment, there are two ways to control the unaligned message printing:
> | 
> |  - use the dmesg command to lower the printing threshold below KERN_WARNING
> |     ("dmesg -n4", IIRC)
> | 
> |  - use prctl --unalign=silent to turn off unaligned printing for a
> |    particular task and its children
> 
> Running prctl on relevant gettys at boot time would have the same effect.
> 
> grant

