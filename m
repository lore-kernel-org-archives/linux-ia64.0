From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 08 Jan 2010 17:35:52 +0000
Subject: Re: [git pull] ia64 changes
Message-Id: <alpine.LFD.2.00.1001080934480.7821@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



On Fri, 8 Jan 2010, Luck, Tony wrote:
> 
> please pull from:
> 
> 	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release
> 
> This will update the files shown below.

Hmm. Pulled, but I think that "struct fnptr" thing in <asm/types.h> should 
_really_ be inside the #ifdef __KERNEL__ that is a few lines down.

There's no way that type is valid to export to user space.

		Linus
