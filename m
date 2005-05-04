From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 04 May 2005 17:26:04 +0000
Subject: RE: catching up on the backlog
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F0366AED8@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200505032108.j43L8wc21277@unix-os.sc.intel.com>
In-Reply-To: <200505032108.j43L8wc21277@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>It appears that you've missed the following two patches:
>
>   date    subject
>   03/22   [PATCH] move nodepda pointer out of pda
>   03/23   [PATCH] convert some sn SAL_CALLs to ia64_sal_oemcall calls

Ok, I've applied these locally.  I can't connect to kernel.org at the
moment (I think the machine I need is being upgraded at the moment). I'll
push them up as soon as I can.

>When I apply them to your 'release' tree then everything builds cleanly.
>By everything, I'm including the 'SGI Altix cross partition functionality'
>patches you just applied. (They're the xp* files listed below.)
>
>Note that to build these I had to set 'CONFIG_IA64_SGI_SN_XP=m' during
>the 'make oldconfig'. (I had copied 'arch/ia64/configs/sn2_defconfig' to
>.config.)

Do you want to send me an updated sn2_defconfig?

>The system booted and ran just fine on an SGI Altix.

Great.  Thanks for testing.

-Tony
