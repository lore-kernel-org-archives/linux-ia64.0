From: Bill Nottingham <notting@redhat.com>
Date: Thu, 07 Dec 2000 16:02:16 +0000
Subject: [Linux-ia64] Re: Re: fail to mount LS120 drive
Message-Id: <marc-linux-ia64-105590678205815@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Andreas Schwab (schwab@suse.de) said: 
> |> Yes, they can be. It's kind of odd, but it's necessary if
> |> you want to use the same boot image for a disk and for
> |> the CD (unless you try and fit an ia64 boot image into
> |> a normal floppy size, which would be rather tight.)
> 
> What's wrong with just copying the files to the floppy?  There is no
> requirement that the boot floppy has a particular size.

True. It's just that if you try to use anything greater than 2.88MB
for a CDROM boot image, it has to be partitioned, and you save
some CD space if you use the same boot image file for both CD and
LS-120.

Bill

