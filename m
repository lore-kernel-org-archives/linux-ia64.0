From: "H . J . Lu" <hjl@valinux.com>
Date: Thu, 16 Nov 2000 02:51:05 +0000
Subject: Re: [Linux-ia64] Recommended compiler for compiling kernels test10 and upper?
Message-Id: <marc-linux-ia64-105590678205728@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205680@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205680@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Nov 15, 2000 at 12:59:50PM -0500, Scott Hankin wrote:
> >>
> >
> >That is what happened to me when my machine was upgraded to B1. I
> >wound up putting a working kernel on the RedHat ia64 bootable LS120
> >floppy and booted it with root=.... It assumes you have RedHat already
> >installed on your machine befor upgrade.
> >
> >--
> >H.J. Lu (hjl@valinux.com)
> 
> Howdy -
> 
> Precisely how did you do that?  I can currently boot from the LS120 disk
> I made from the Red Hat CD, but when I mount it, the directory listing
> is garbage, leading me to believe that the format is not that of a Linux
> filesystem.  I have a new kernel - what do I do to get it on the LS120?
> 

As Jim said, it is an EFI partition. You can do

# mount -t vfat /dev/hdd1 /mnt/floppy/

Or you can use mtools.

-- 
H.J. Lu (hjl@valinux.com)

