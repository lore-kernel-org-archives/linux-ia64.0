From: Rich Altmaier <richa@engr.sgi.com>
Date: Fri, 22 Jun 2001 22:50:39 +0000
Subject: Re: [Linux-ia64] IO/TLB bounce buffer space
Message-Id: <marc-linux-ia64-105590693005752@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005716@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005716@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This is just a note to comment on the mention of:
  Thus, worst case buffer usage would be 8kB * 253 * 16 * 4 = 126 MB only
  for this driver! Of course it is highly unlikely that all these buffers
  will be in use simultaneously.

In my experience, the question of the peak demand a system may
experience must be governed by
1. what you, the supplier, spec as the peak demand it supports,
2. what the customer understands is the max load the system
    can be utilized to perform, and have paid to obtain.
3. and any shortfall in actual delivered performance from your spec
    you can be sure the customer will demand you the supplier pay
    to make up the difference!

This leaves no room for statistical analysis!   The customer will not
view that using all the resources at once is unlikely and not expected.
If you spec 4 controllers of 32 devices each of 253 buffers needed for
their peak operation, then the system better deliver this.
Or you should change your spec and reduce the numbers.

Please don't design for 4 controllers of 32 devices that just limp along.
Either they run at full performance all the time, or reduce the numbers
to what can be supported!   How can the customer, who lays out the
dollars for 4*32 devices, interpret this otherwise?

Of course you can also take an approach of specing a max aggregate
bandwidth, to be "fairly" allocated across all devices.   This is another
approach that can work, although you will spend a year or so getting
"fairly" to satisfy all customers.   Better to pull down your config
until peak really works.

Thanks, Rich

Rich Altmaier
SGI



