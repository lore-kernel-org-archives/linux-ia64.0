From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 09 Oct 2003 01:48:18 +0000
Subject: Re: basic questions regarding clone2()
Message-Id: <marc-linux-ia64-106566412314302@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106518282910795@msgid-missing>
In-Reply-To: <marc-linux-ia64-106518282910795@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 03 Oct 2003 14:07:39 +0200, Jacky Malcles <Jacky.Malcles@bull.net> said:

  Jacky> with ia64, clone2() doesn't set errno to EINVAL when a zero
  Jacky> value is specified for child-stack parameter.

Why would you expect EINVAL in this case?

  Jacky> what i'd like to know:

  Jacky> - is clone2() code subject to change shortly?

There are no plans for changes to clone2().

  Jacky> - what should be expected when child-stack is zeroed

Not sure what you mean here.

  Jacky> - where can i find a manual page ?

Don't know of a man-page per se, but the ia64 linux kernel design &
implementation book has a fairly detailed description of clone2().
clone2() is really just clone() with an explicit stack-range, though.

	--david
