From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 12 Apr 2002 05:31:04 +0000
Subject: Re: [Linux-ia64] new kernel patch (relative to 2.5.8-pre3)
Message-Id: <marc-linux-ia64-105590701905439@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905293@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905293@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 11 Apr 2002 20:50:35 -0700, Greg KH <greg@kroah.com> said:

  Greg> There is a uhci.c (sorry, meant to say this, instead of
  Greg> usb-uhci.c) change in the patch you just posted on kernel.org.
  Greg> Your diffstat says there is also a change to usb-ohci.c, but
  Greg> that doesn't show up in your patch.

This is really bugging you, eh? ;-)

  Greg> And it looks like the ia64.bkbits.net/to-linus-2.5 doesn't
  Greg> contain all of the changes you have listed in the patch you
  Greg> just posted, right?

Like I said: it's simply what the script produced.

  Greg> Is there a bk tree somewhere I can clone that matches up with
  Greg> your working tree right now?  I'd like to get that usb patch
  Greg> out of there :)

No, the lia64 patch is a union of about a dozen bk trees.  I'm
chipping away one tree after another, as Linus merges stuff, until at
the end only to-linus-2.5 is left.  I did make the union tree
available in the past, but it was a pain to maintain (it's a throwaway
tree and bkbits.net isn't well setup to handle that, as far as I can
tell).

Anyhow, I modified the tree containing the temporary hacks to omit the
uhci.c change.  I'm not sure whether the comment will be gone (I
suspect not, given bk's tendency never to forget anything), but the
patch should be correct.

	--david

