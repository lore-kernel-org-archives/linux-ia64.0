From: Greg KH <greg@kroah.com>
Date: Fri, 12 Apr 2002 00:46:38 +0000
Subject: Re: [Linux-ia64] new kernel patch (relative to 2.5.8-pre3)
Message-Id: <marc-linux-ia64-105590701905432@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905293@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905293@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Apr 11, 2002 at 04:49:51PM -0700, David Mosberger wrote:
>  drivers/usb/uhci.c                      |    2 
>  drivers/usb/usb-ohci.c                  |   10 

These diffs aren't in this patch.  Is this the correct diffstat
output for this patch?

And any reason you still have the uhci.c patch in your tree?
It should work properly without that patch.  And I don't see
a patch for usb-ohci.c.

thanks,

greg k-h

