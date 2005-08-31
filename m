From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 31 Aug 2005 17:15:17 +0000
Subject: Testing Keith's MCA/INIT patch (was RE: git pull on ia64 linux tree)
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F044726E4@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>What testing would you like to see?

As much testing as possible :-)

I think most platforms have some way to generate an INIT (either
a front panel button like on Tiger, or by asking the maintenance
processor to generate one).  So it would be good to hear an Ack
from as many different platforms as possible.

MCA testing is somewhat harder as it requires specialized h/w
and/or s/w to inject the error.  But I know that some of you can
do this ... so I'd like to hear what happens.

>I do not understand the issues enough
>to comment on the patches, but could possibly coax a couple other people
>who are into spending a half-day on it.

The more eyes the better.  Even better than coaxing someone to
look at this would be coaxing them to explain it to you (they'll
have to look harder, and you'll learn more about this code).

-Tony
