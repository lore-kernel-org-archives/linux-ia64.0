From: Grant Grundler <iod00d@hp.com>
Date: Tue, 11 Apr 2006 01:55:35 +0000
Subject: Re: booting with `mem=' on an Altix (or other NUMA machine)
Message-Id: <20060411015535.GB31869@esmail.cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <17467.2252.70039.423224@wombat.chubb.wattle.id.au>
In-Reply-To: <17467.2252.70039.423224@wombat.chubb.wattle.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Apr 11, 2006 at 11:39:24AM +1000, Peter Chubb wrote:
> 
> Looks like booting with mem=xxx doesn't work very well on a NUMA
> machine ... one sees, `ernel panic - not syncing: pernode space for
> node 1 could not be allocated!'
> 
> It is intended that the mem= command line work?  It would have to be
> quite a bit more complex if so, to spread the memory across online nodes.

that was discussed before:
http://marc.theaimsgroup.com/?l=linux-ia64&m9718964113183&w=2

hth,
grant
