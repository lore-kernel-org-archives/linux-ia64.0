From: Christopher Wedgwood <cw@sgi.com>
Date: Wed, 16 Jul 2003 18:23:58 +0000
Subject: Re: [PATCH] (2.4.21-bjorn-bk) Minimalist PAL mapping for SN2
Message-Id: <marc-linux-ia64-105838014023148@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105832171829546@msgid-missing>
In-Reply-To: <marc-linux-ia64-105832171829546@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jul 16, 2003 at 08:22:37AM -0700, Luck, Tony wrote:

> If SN2 guarantees that the PAL code is the only executable code in
> the whole of your mixed cacheability granule, then this code is
> safe.

Yes, for SN2 this works and is what I presently use here.

Somewhere I have/had an instrumented version of the ivt code which
allows to to profile fault patterns across regions and such-like, by
sucking data our of /proc and making pretty graphs --- I wrote this
mostly to ensure what I thought was going on really was and also to
get some idea of the distribution of things.

Since it doesn't affect non-SN2 users I'm hoping to get something like
this merged if nobody objects...


  --cw
