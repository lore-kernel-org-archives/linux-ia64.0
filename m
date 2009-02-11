From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 11 Feb 2009 18:58:19 +0000
Subject: RE: [PATCH] SGI IA64 UV: fix ia64 build error in the linux-next	tree
Message-Id: <57C9024A16AD2D4C97DC78E552063EA361689D7D@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090209162520.GA4882@sgi.com>
 <20090210132555.be1c1462.akpm@linux-foundation.org>
 <20090211150103.GA15814@sgi.com> <20090211150536.GE10525@elte.hu>
In-Reply-To: <20090211150536.GE10525@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>, Dean Nelson <dcn@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, linux-ia64 <linux-ia64@vger.kernel.org>, linux-next <linux-next@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

> What question was that? Folding back across that distance is not possible
> in a Git workflow. I do regular cross-builds - the build bug did not trigger
> with the ia64 defconfig.

I'm confused by this, as it definitely triggered for me.  Perhaps
my build scripts do things a bit differently.  Essentially I do:

        $ for c in `ls arch/ia64/configs`
        > do
        >       cp arch/ia64/configs/$i .config
        >       yes '' | make oldconfig
        >       make
        > done

Which takes the default answer for any new questions that crop
up.  This enabled the GRU driver in the case of the generic_defconfig,
and so the build failed because of the lack of asm/uv.h

-Tony
