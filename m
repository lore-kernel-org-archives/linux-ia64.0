From: Tony Luck <tony.luck@intel.com>
Date: Mon, 26 Oct 2009 18:24:00 +0000
Subject: Re: [PATCH -next] ia64/sn: fix percpu warnings
Message-Id: <12c511ca0910261124p64f2ad5emc88d00b9957482b3@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20091014163445.f0441473.sfr@canb.auug.org.au>
	 <20091014151003.0ef42973.randy.dunlap@oracle.com>
	 <4AD67C05.2030201@kernel.org>
In-Reply-To: <4AD67C05.2030201@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Tejun Heo <tj@kernel.org>, Randy Dunlap <randy.dunlap@oracle.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, Jes Sorensen <jes@sgi.com>, linux-ia64@vger.kernel.org, linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, akpm <akpm@linux-foundation.org>

> Acked-by: Tejun Heo <tj@kernel.org>
>
> Can this go through ia64 tree? =A0If not, I can route it through
> percpu#for-fixes.

It can ... but I'm getting a strange warning since I applied it:

  Building modules, stage 2.
  GZIP    arch/ia64/hp/sim/boot/vmlinux.gz
  MODPOST 198 modules
WARNING: "per_cpu____sn_cnodeid_to_nasid" [drivers/misc/sgi-xp/xpc.ko]
has no CRC!

Any idea what this means?

-Tony
