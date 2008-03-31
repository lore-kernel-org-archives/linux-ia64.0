From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Date: Mon, 31 Mar 2008 07:53:26 +0000
Subject: Re: [PATCH 3/4] s390 renumber TIF_RESTORE_SIGMASK
Message-Id: <1206950006.26149.0.camel@localhost>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080329001230.D013726FA1D@magilla.localdomain>
	 <20080329001418.D5F3526FA1D@magilla.localdomain>
In-Reply-To: <20080329001418.D5F3526FA1D@magilla.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Roland McGrath <roland@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-s390@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, 2008-03-28 at 17:14 -0700, Roland McGrath wrote:
> TIF_RESTORE_SIGMASK no longer needs to be in the _TIF_WORK_* masks.
> Those low bits are scarce, and are all used up now.
> Renumber TIF_RESTORE_SIGMASK to free one up.
> 
> Signed-off-by: Roland McGrath <roland@redhat.com>

Acked-by: Martin Schwidefsky <schwidefsky@de.ibm.com>

-- 
blue skies,
  Martin.

"Reality continues to ruin my life." - Calvin.


