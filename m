From: Anton Blanchard <anton@samba.org>
Date: Tue, 17 Feb 2004 23:48:49 +0000
Subject: Re: radeon warning on 64-bit platforms
Message-Id: <20040217234848.GB22534@krispykreme>
List-Id: <linux-ia64.vger.kernel.org>
References: <16434.35199.597235.894615@napali.hpl.hp.com> <1077054385.2714.72.camel@thor.asgaard.local> <16434.36137.623311.751484@napali.hpl.hp.com> <1077055209.2712.80.camel@thor.asgaard.local> <16434.37025.840577.826949@napali.hpl.hp.com> <1077058106.2713.88.camel@thor.asgaard.local> <16434.41884.249541.156083@napali.hpl.hp.com>
In-Reply-To: <16434.41884.249541.156083@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davidm@hpl.hp.com
Cc: torvalds@osdl.org, Michel D?nzer <michel@daenzer.net>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org


> Here is a proposed patch for fixing the compile-warning that shows up
> when compiling radeon_state.c on a 64-bit platform (Itanium, in my
> case).  According to Michel, RADEON_PARAM_SAREA_HANDLE is used only on
> embedded platforms and since it is not possible to fix the problem
> without breaking backwards-compatibility for those platforms, the
> interim fix is to simply desupport this particular ioctl() on 64-bit
> platforms (i.e., make it fail with EINVAL).
> 
> If there are no objections, please apply.

A small thing, could the comment be constrained to 80 columns? :)

Anton
