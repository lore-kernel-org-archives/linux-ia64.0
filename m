From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 26 Oct 2005 21:19:09 +0000
Subject: RE: CONFIG_SGI_SN_XP=m doesn't boot on zx1
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F04C8C784@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1130359742.7335.115.camel@localhost>
In-Reply-To: <1130359742.7335.115.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Setting CONFIG_SGI_SN_XP=m (which forces CONFIG_GENERIC_ALLOCATOR=y and
>CONFIG_IA64_UNCACHED_ALLOCATOR=y) causes my rx2600 to MCA when booting
>the latest aegl git tree, before any messages are printed to the screen.
>Complete .config file attached.  
>
>I'm going to disable this module in the Debian kernel tree for now.

I think that this is fixed in the "test" branch of my GIT tree ... if
you have time could you give that a try?

-Tony

