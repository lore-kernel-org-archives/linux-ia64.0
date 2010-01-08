From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 08 Jan 2010 17:49:14 +0000
Subject: RE: [git pull] ia64 changes
Message-Id: <987664A83D2D224EAE907B061CE93D530C51CDC2@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Hmm. Pulled, but I think that "struct fnptr" thing in <asm/types.h> should 
> _really_ be inside the #ifdef __KERNEL__ that is a few lines down.
>
> There's no way that type is valid to export to user space.


Oops.  Yes.  I'll move it in another patch.

-Tony
