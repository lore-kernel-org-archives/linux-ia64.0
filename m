From: dann frazier <dannf@hp.com>
Date: Tue, 01 Jun 2004 00:22:42 +0000
Subject: Re: IA64_GENERIC vs. NUMA/DISCONTIG/VIRTUAL_MEM_MAP
Message-Id: <20040601002242.GA32508@dannf.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040531044843.GA25705@dannf.org>
In-Reply-To: <20040531044843.GA25705@dannf.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, May 31, 2004 at 05:42:38PM +0200, Andreas Schwab wrote:
> dann frazier <dannf@hp.com> writes:
> 
> > I suspected that initially, but this is what confused me:
> > $ make oldconfig > /dev/null && grep IA64_GENERIC .config && grep CONFIG_NUMA .config
> > CONFIG_IA64_GENERIC=y
> > # CONFIG_NUMA is not set
> 
> Can't reproduce here.  Whenever I select IA64_GENERIC I also get NUMA=y,
> even if I start with a .config that has NUMA=n.

Seems the machine I was doing my builds on has crashed, and I'm out of the country
at the moment - I can send my config when I regain access.
