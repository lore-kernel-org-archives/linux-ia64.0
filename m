From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 12 Apr 2002 02:15:47 +0000
Subject: Re: [Linux-ia64] new kernel patch (relative to 2.5.8-pre3)
Message-Id: <marc-linux-ia64-105590701905437@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905293@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905293@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 11 Apr 2002 18:04:14 -0700, Greg KH <greg@kroah.com> said:

  Greg> I think the patch on kernel.org for usb-uhci.c is not needed
  Greg> anymore.  Do you want me to send you a changeset against your
  Greg> ia64.bkbits.net tree?

There is no change for usb-uhci.c.  There was one in the past, which
resulted in a conflict when pulling from Linus' 2.5.8-pre3 tree.
During the merge, I opted to use Linus' version.  I don't know why
it's showing up in the changeset.

  Greg> You could generate the patch directly by doing: bk export
  Greg> -tpatch -rv2.5.8-pre3..+ -h > patch instead of diffing against
  Greg> the two tree.

Ah, thanks for the tip.

	--david

