From: jbarnes@sgi.com (Jesse Barnes)
Date: Wed, 15 Oct 2003 03:03:36 +0000
Subject: Re: GENERIC still failing?
Message-Id: <marc-linux-ia64-106618705313595@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106617635106445@msgid-missing>
In-Reply-To: <marc-linux-ia64-106617635106445@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Oct 14, 2003 at 07:40:44PM -0700, Randy.Dunlap wrote:
> On Wed, 15 Oct 2003 12:15:48 +1000 Ian Wienand <ianw@gelato.unsw.edu.au> wrote:
> 
> | On Tue, Oct 14, 2003 at 05:22:05PM -0700, Jesse Barnes wrote:
> | > Looks like CONFIG_NUMA and CONFIG_DISCONTIGMEM are missing from the
> | > config being built.  A generic kernel won't work without them.
> | 
> | mea culpa, as usual. Is there some way to make it when you select
> | generic it always requires CONFIG_NUMA/DISCONTIGMEM?
> 
> Yes, use "select" (see Documentation/kbuild/kconfig-language.txt).
> E.g.,
> 
> config GENERIC
> 	bool "blah"
> 	select NUMA
> 	select DISCONTIGMEM
> 	---help---

Ok, thanks.  I'll send out a patch tomorrow unless someone beats me to
it.

Jesse
