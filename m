From: Greg KH <greg@kroah.com>
Date: Fri, 12 Apr 2002 03:50:35 +0000
Subject: Re: [Linux-ia64] new kernel patch (relative to 2.5.8-pre3)
Message-Id: <marc-linux-ia64-105590701905438@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905293@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905293@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Apr 11, 2002 at 07:15:47PM -0700, David Mosberger wrote:
> >>>>> On Thu, 11 Apr 2002 18:04:14 -0700, Greg KH <greg@kroah.com> said:
> 
>   Greg> I think the patch on kernel.org for usb-uhci.c is not needed
>   Greg> anymore.  Do you want me to send you a changeset against your
>   Greg> ia64.bkbits.net tree?
> 
> There is no change for usb-uhci.c.  There was one in the past, which
> resulted in a conflict when pulling from Linus' 2.5.8-pre3 tree.
> During the merge, I opted to use Linus' version.  I don't know why
> it's showing up in the changeset.

There is a uhci.c (sorry, meant to say this, instead of usb-uhci.c)
change in the patch you just posted on kernel.org.  Your diffstat says
there is also a change to usb-ohci.c, but that doesn't show up in your
patch.

And it looks like the ia64.bkbits.net/to-linus-2.5 doesn't contain all
of the changes you have listed in the patch you just posted, right?

Is there a bk tree somewhere I can clone that matches up with your
working tree right now?  I'd like to get that usb patch out of there :)

thanks,

greg k-h

