From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 28 Sep 2009 23:01:25 +0000
Subject: RE: [git pull] ia64 changes
Message-Id: <alpine.LFD.2.01.0909281555580.6996@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



On Mon, 28 Sep 2009, Linus Torvalds wrote:
>
> Or did I miss something?

Never mind, it's all fine. It just depends on what you define "unlocked" 
to be, and "old value matches high bits is unlocked" is obviously the more 
attractive case than the one I was thinking of ("new value matches high 
bits"), since it makes a zero initializer be unlocked.

And it's what x86 does too. I don't know why I expected the "new value 
is the ticket" case.

		Linus
