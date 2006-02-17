From: Jes Sorensen <jes@sgi.com>
Date: Fri, 17 Feb 2006 18:08:49 +0000
Subject: Re: [patch] option to quite unaligned trap warnings
Message-Id: <yq04q2xyi1a.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq0hd772nhj.fsf@jaguar.mkp.net>
In-Reply-To: <yq0hd772nhj.fsf@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Tony" = Luck, Tony <tony.luck@intel.com> writes:

>> I kinda added that deliberately to make it a strong point to the
>> users that they really should consider fixing their apps. If we do
>> a simple message like that they may not realize the cost of it.
>> 
>> I can live with the simple message, but I think it would be good to
>> swing the cluebat a bit ;-)

Tony> The clueless users won't ever see your message as the default is
Tony> for them to still keep seeing messages every (rate limited) time
Tony> their broken applications make a misaligned access.  They need
Tony> to have somehow found a clue someplace to work out how to turn
Tony> these messages off ... hopefully there is some correlation
Tony> between them finding that clue and knowing that an unaligned
Tony> access is bad for performance.

I guess the risk is that there are clueful users and clueless admins,
the latter being the ones disabling this feature.

Anyway if you prefer a simpler text then I am ok with it, getting the
functionality in solves the problem I was facing.

Thanks,
Jes
