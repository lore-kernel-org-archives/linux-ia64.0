From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 16 Dec 2004 18:38:15 +0000
Subject: RE: [very very drafty] prezeroing to increase the page fault rate
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02900FBD@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0412141832350.6975@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0412141832350.6975@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>> > Also just a stupid question - would an madvise(..., MADV_PREFAULT)
>> > be of use to you? Or is that too difficult to get a good NUMA
>> > allocation layout?
>> 
>> Its easy to implement. The current code already checks for MADV_RAND and
>> switches off prefaulting for that case.
>
>Oh yeah that could be useful too (ie. pre-enlarging the 
>prefault window)
>
>What I had meant though is: MADV_PREFAULT will allocate pages and
>instantiate ptes and allocate pages for the region specified. So your
>large app would call that on startup and not take any faults in future.

How does that differ from (the already existing) MADV_WILLNEED?

There is also a MADV_SEQUENTIAL ... perhaps that could be used to
kick the prefaulter into higher gear (perhaps go directly to order
2, or more, allocation, instead of ramping up slowly).

-Tony
