From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 09 May 2003 21:43:22 +0000
Subject: RE: [Linux-ia64] Re: [PATCH] head.S fix for unusual load addrs
Message-Id: <marc-linux-ia64-105590723705712@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705550@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705550@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Not that I can see--we've been using that method for awhile now with
> good success, and I'd be happy to test any 2.5 patches that implement
> this feature.  So I guess we should go with virtual remapping?  Tony?

I started looking at porting the most recent version of my patch
(last seen around 2.5.39 ... only has the relocation, but once that
is it, adding kernel text replication is a relatively simple evolutionary
step).

I've been teaching a class all morning, and part of the afternoon, so
no demonstrable progress ... but most of the merge errors have been
cleaned up.  Now looking last (and biggest) reject in head.S.

-Tony

