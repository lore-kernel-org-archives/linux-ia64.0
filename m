From: David Rientjes <rientjes@google.com>
Date: Mon, 21 Sep 2009 22:55:01 +0000
Subject: Re: [PATCH] remove duplicate asm/mman.h files
Message-Id: <alpine.DEB.1.00.0909211553000.30561@chino.kir.corp.google.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1251197514.git.ebmunson@us.ibm.com> <200909181848.42192.arnd@arndb.de> <alpine.DEB.1.00.0909181236190.27556@chino.kir.corp.google.com> <200909211031.25369.arnd@arndb.de> <alpine.DEB.1.00.0909210208180.16086@chino.kir.corp.google.com>
 <Pine.LNX.4.64.0909211258570.7831@sister.anvils>
In-Reply-To: <Pine.LNX.4.64.0909211258570.7831@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Fenghua Yu <fenghua.yu@intel.com>, Tony Luck <tony.luck@intel.com>, ebmunson@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org, mtk.manpages@gmail.com, Randy Dunlap <randy.dunlap@oracle.com>, rth@twiddle.net, ink@jurassic.park.msu.ru, linux-ia64@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>

On Mon, 21 Sep 2009, Hugh Dickins wrote:

> Is it perhaps the case that some UNIX on ia64 does implement MAP_GROWSUP,
> and these numbers in the Linux ia64 mman.h have been chosen to match that
> reference implementation?  Tony will know.  But I wonder if you'd do
> better at least to leave a MAP_GROWSUP comment on that line, so that
> somebody doesn't go and reuse the empty slot later on.
> 

Reserving the bit from future use by adding a comment may be helpful, but 
then let's do it for MAP_GROWSDOWN too.
