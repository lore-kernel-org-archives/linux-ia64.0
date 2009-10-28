From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 28 Oct 2009 16:24:22 +0000
Subject: RE: [PATCH -next] ia64/sn: fix percpu warnings
Message-Id: <57C9024A16AD2D4C97DC78E552063EA3E34C0108@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20091014163445.f0441473.sfr@canb.auug.org.au>
	 <20091014151003.0ef42973.randy.dunlap@oracle.com>
	 <4AD67C05.2030201@kernel.org>
 <12c511ca0910261124p64f2ad5emc88d00b9957482b3@mail.gmail.com>
 <57C9024A16AD2D4C97DC78E552063EA3E345953E@orsmsx505.amr.corp.intel.com>
 <4AE85D28.90809@kernel.org>
In-Reply-To: <4AE85D28.90809@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tejun Heo <tj@kernel.org>
Cc: Randy Dunlap <randy.dunlap@oracle.com>, Stephen Rothwell <sfr@canb.auug.org.au>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, akpm <akpm@linux-foundation.org>

> Umm... the correct correct declaration and definition would be
> 
> DECLARE_PER_CPU(short [MAX_COMPACT_NODES], __sn_cnodeide_to_nasid);
>
> and
>
> DEFINE_PER_CPU(short [MAX_COMPACT_NODES], __sn_cnodeide_to_nasid);
>
> So that the first part contains full type.  Doing it the other way
> might cause problems if the __weak trick is turned on.

That's what Randy's patch uses ... but doing it the "right" way gives
me the "has no CRC!" warning.

This seems to be a feature of exported per cpu arrays.  If I hack
up a driver to make use of softirq_work_list, I see a similar
no CRC warning for it.

Is this problem in the ia64 tool chain[1]?  Or do other architectures
have problems with exported per cpu arrays?

-Tony

[1] My default toolchain is uses gcc 4.1.2.  But 4.4.1 has the same
behavior.

