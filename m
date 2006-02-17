From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 17 Feb 2006 18:05:33 +0000
Subject: RE: [patch] option to quite unaligned trap warnings
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F05BBF46D@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq0hd772nhj.fsf@jaguar.mkp.net>
In-Reply-To: <yq0hd772nhj.fsf@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I kinda added that deliberately to make it a strong point to the users
> that they really should consider fixing their apps. If we do a simple
> message like that they may not realize the cost of it.
>
> I can live with the simple message, but I think it would be good to
> swing the cluebat a bit ;-)

The clueless users won't ever see your message as the default is for
them to still keep seeing messages every (rate limited) time their
broken applications make a misaligned access.  They need to have
somehow found a clue someplace to work out how to turn these messages
off ... hopefully there is some correlation between them finding that
clue and knowing that an unaligned access is bad for performance.

-Tony
