From: Jes Sorensen <jes@trained-monkey.org>
Date: Thu, 25 Sep 2003 07:21:24 +0000
Subject: Re: QLogic drivers in 2.4
Message-Id: <marc-linux-ia64-106447503610716@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106399415917430@msgid-missing>
In-Reply-To: <marc-linux-ia64-106399415917430@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Christoph" = Christoph Hellwig <hch@infradead.org> writes:

Christoph> Well, that someone is qlogic.  But I don's see why it
Christoph> should go into the ia64 tree.  Once qlogic got the driver
Christoph> in shape it and/or the feral driver should go into
Christoph> mainline.  This is actually on the 2.6 should-fix list.

Hi,

I am a little wary of pushing the Feral driver to mainstraim in it's
current state (well at least the state it was in a few months ago when
I last looked). It's register access macros suffers from being
multi-OS wrappers and it got memory ordering and posted writes
completely wrong. It's certainly fixable, but if we push it for
mainline, I'd really like to see someone swing the club over it a bit
and convince it to be a little more Linuxy.

I understand the heritage of the Feral driver, so please don't take
this as a rant, it's merely an issue of what the target for the driver
is.

Cheers,
Jes

