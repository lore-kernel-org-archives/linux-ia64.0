From: Bill Nottingham <notting@redhat.com>
Date: Mon, 06 Nov 2000 17:08:39 +0000
Subject: [Linux-ia64] Re: RE: Out of memory panic on boot...
Message-Id: <marc-linux-ia64-105590678205659@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Ross Ridge (ross@sitraka.com) said: 
> Ken Hill writes:
> > sounds like you copied the kernel to /boot/efi using the copy
> > command instead of using cat.
> 
> Just out of curiousity does anyone know why using "cp" rather than
> "cat" would be a problem?  I can't find anything in the archives for
> this mailing list explaining the problem.  My only guess is some sort
> of bug involving sparse files.

There was a problem with this in earlier kernels. I think it's been
fixed for a few months now.

Bill

