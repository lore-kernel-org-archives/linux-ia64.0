From: Bob Picco <bob.picco@hp.com>
Date: Mon, 26 Sep 2005 23:35:32 +0000
Subject: Re: [PATCH 0/4] V4 ia64 SPARSEMEM
Message-Id: <20050926233532.GL16066@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050922161418.GW16066@localhost.localdomain>
In-Reply-To: <20050922161418.GW16066@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

luck wrote:	[Mon Sep 26 2005, 04:40:36PM EDT]
> >This patchset differs very little from V3. It requires SPARSEMEM EXTREME
> >patches which are in 2.6.14-rcX.
> 
> Bob,
> 
> Can you provide a bit more of a write up on what this change means?
> Which config options have gone, what the new ones, and what are the
> rules that determine what's legal.  The help options in Kconfig don't
> seem very helpful here.
I'm assuming you refer to the config changes in arch/ia64/Kconfig. Well the
new ones are documented in mm/Kconfig.  If that documentation is inadequate,
then I can attempt to supply more.
> 
> I think it would be a good idea to bundle a set of changes to the
> default config files along with this change ... which means we should
> have a discussion on what are the sensible defaults out of the new
> array of options, and which of the non-default options are still
> popular enough that I should make sure to test build them in my
> regular scripts.  Right now this whole change is a close to being
> a no-op as none of the default configs enables SPARSEMEM.
This is true and just about universally true for other arches with SPARSEMEM
enabled. I took a quick look and only i386 selects SPARSEMEM for NUMA.
I couldn't find any default config files with SPARSEMEM.  I think the objective
was for more soak time before defaulting to SPARSEMEM. Also just a few
arches have SPARSEMEM support.  Dave Hansen can possibly fill in my gaps.
> 
> So can you throw together a straw-man proposal for each of the
> default configs (maybe SGI can provide the sn2 version)?  I'm assuming
> here that SPARSEMEM is going to be the preferred choice for some
> system(s) ... I'm just not sure which.
We could be more aggressive than other arches but still follow the cautious
path.  I'm reluctant to suggest this but adding a couple of default 
configuration files with SPARSEMEM might be useful.  Perhaps 
sn2_defconfig_sparsemem and defconfig_sparsemem. 

Certainly a more aggressive strategy would be any config with DISCONTIG,
VIRTUAL_MEM_MAP and  NUMA be change to SPARSEMEM and NUMA.  We've only
have performance numbers done for a large Altix configuration and rx2600.
Tiger, rx2600, Altix and HP Architecture Simulator for NUMA are the only known
machines tested with SPARSEMEM. It's doubtful there would be issues but 
doesn't seem like a good strategy.

Should you think we won't get sufficient test converage without some default
configuration files, then I'd suggest the two mentioned about be introduced.
Long term should SPARSEMEM become the default and DISCONTIG+VIRTUAL_MEM_MAP
be obsoleted then we could remove the config files.
> 
> -Tony

bob
