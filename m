From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 23 Aug 2004 17:45:23 +0000
Subject: RE: IA64 bitkeeper trees (again)
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F01E5EC56@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4123D3A2.2050609@intel.com>
In-Reply-To: <4123D3A2.2050609@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Ian Wienand wrote:
>On Wed, Aug 18, 2004 at 10:09:38PM +0000, Tony Luck wrote:
>> The actual names all have "linux-ia64-" prepended.  E.g.
>> 
>>   http://lia64.bkbits.net/linux-ia64-test-2.6.9
>> 
>> The names of the trees all change when Linus makes a release.
>
>I don't know how or if it's even possible, but is there some way to
>make a linux-ia64-test-latest symbolic link (or something) that you
>can pull from to always have the latest testing tree?

It wasn't possible last week ... but "ask and ye shall receive". Larry
McVoy added a symlink feature to the bkbits.net admin interface for us
(Thanks Larry).

So what would you like the names of the symlinks to be?  I'm thinking
of:

   linux-ia64-release-2.6.8.1 -> release-2.6
   linux-ia64-test-2.6.8.1    -> test-2.6
   linux-ia64-release-2.6.9   -> release-2.6.next
   linux-ia64-test-2.6.9      -> test-2.6.next

but I'd be happy to entertain better suggstions.

-Tony
