From: Greg KH <greg@kroah.com>
Date: Fri, 12 Apr 2002 01:04:14 +0000
Subject: Re: [Linux-ia64] new kernel patch (relative to 2.5.8-pre3)
Message-Id: <marc-linux-ia64-105590701905436@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905293@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905293@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Apr 11, 2002 at 05:49:12PM -0700, David Mosberger wrote:
> >>>>> On Thu, 11 Apr 2002 17:46:38 -0700, Greg KH <greg@kroah.com> said:
> 
>   Greg> On Thu, Apr 11, 2002 at 04:49:51PM -0700, David Mosberger
>   Greg> wrote:
>   >> drivers/usb/uhci.c | 2 drivers/usb/usb-ohci.c | 10
> 
>   Greg> These diffs aren't in this patch.  Is this the correct
>   Greg> diffstat output for this patch?
> 
> Apparently not. ;-)
> 
> I used to bk-make-sum script to create it, perhaps it has a bug.
> The final authority is the patch on kernel.org.  If you see something
> wrong there, please let me know.

I think the patch on kernel.org for usb-uhci.c is not needed anymore.
Do you want me to send you a changeset against your ia64.bkbits.net
tree?

bk-make-sum shows what is needed to send to Linus to sync with your
tree.  As the USB subsystem had a bunch of files moved around, the diff
generated is a bit odd.

You could generate the patch directly by doing:
	bk export -tpatch -rv2.5.8-pre3..+ -h > patch
instead of diffing against the two tree.

thanks,

greg k-h

