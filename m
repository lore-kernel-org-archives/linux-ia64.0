From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 24 Aug 2006 16:09:44 +0000
Subject: RE: [PATCH] 80-column reformatting for fsys.S
Message-Id: <617E1C2C70743745A92448908E030B2A6E96E8@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1156288081.7332.15.camel@fcboson.fc.hp.com>
In-Reply-To: <1156288081.7332.15.camel@fcboson.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> > Could you convert the C++ comments to C comments while you are at it?
>
> Good idea.  I'll try to make a second pass on the ones I've done,
> and make it a point to do it in the future.

I'm not so sure that this is such a great idea ... using C comments will
trim another 2 or three characters off the space you have available
on each line (depending on whether you like /*comment*/ or /* comment */)
so you will either need to be more terse in order to fit, or have more
comments run onto two lines, neither of which sound like an improvememt
to maintainability).

The 80-column rule has considerable merit (I like to have two code
windows side-by-side, and my employer has shown no signs of wanting
to shell out for a 24+" monitor for me :-( ... but I'm really not
so sure why people are so anti-c++ comments {BTW, I don't see this
prohibition in Documentation/CodingStyle ... is this just another
unwritten rule that everyone knows about?)

-Tony
