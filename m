From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 04 Aug 2008 20:34:35 +0000
Subject: RE: [Patch 2/2] update generic_defconfig to support sn2.
Message-Id: <57C9024A16AD2D4C97DC78E552063EA308328FA7@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080802183527.GA7290@sgi.com>
In-Reply-To: <20080802183527.GA7290@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Dean and I just talked.  We think it should really be:
>
>         depends on (IA64_GENERIC || IA64_SGI_SN2 || IA64_SGI_UV || X86_64) && SMP
>         select IA64_UNCACHED_ALLOCATOR if IA64_GENERIC || IA64_SGI_SN2
>         select GENERIC_ALLOCATOR if IA64_GENERIC || IA64_SGI_SN2
>         select SGI_GRU if (IA64_GENERIC || IA64_SGI_UV || X86_64) && SMP
>
> Could you give it a try?  If not, Dean or I can try it tomorrow.

Yes.  That works (not sure why I didn't manage to spot what is
almost the same messed up expression just three lines above the
one that I did see).

I'll fix it like that. Thanks.

-Tony
