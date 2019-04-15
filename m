From: Michal Hocko <mhocko@kernel.org>
Date: Mon, 15 Apr 2019 11:42:09 +0000
Subject: Re: [PATCH 0/2] x86, numa: always initialize all possible nodes
Message-Id: <20190415114209.GJ3366@dhcp22.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190212095343.23315-1-mhocko@kernel.org>
 <20190226131201.GA10588@dhcp22.suse.cz>
In-Reply-To: <20190226131201.GA10588@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-mm@kvack.org
Cc: Pingfan Liu <kernelfans@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <peterz@infradead.org>, x86@kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>

On Tue 26-02-19 14:12:01, Michal Hocko wrote:
> On Tue 12-02-19 10:53:41, Michal Hocko wrote:
> > Hi,
> > this has been posted as an RFC previously [1]. There didn't seem to be
> > any objections so I am reposting this for inclusion. I have added a
> > debugging patch which prints the zonelist setup for each numa node
> > for an easier debugging of a broken zonelist setup.
> > 
> > [1] http://lkml.kernel.org/r/20190114082416.30939-1-mhocko@kernel.org
> 
> Friendly ping. I haven't heard any complains so can we route this via
> tip/x86/mm or should we go via mmotm.

It seems that Dave is busy. Let's add Andrew. Can we get this [1] merged
finally, please?

[1] http://lkml.kernel.org/r/20190212095343.23315-1-mhocko@kernel.org
-- 
Michal Hocko
SUSE Labs
