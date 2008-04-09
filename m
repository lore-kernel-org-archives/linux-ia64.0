From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Wed, 09 Apr 2008 09:01:39 +0000
Subject: Re: [PATCH 01/23] ia64/xen: introduce synch bitops which is necessary for	ia64/xen support.
Message-Id: <20080409090139.GA2583%yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <12077166303062-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <12077166303062-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Apr 09, 2008 at 12:09:51AM -0500, Jeremy Fitzhardinge wrote:

> >+#define sync_cmpxchg	ia64_cmpxchg4_acq
> >  
> 
> Please always use arguments with function-like macros, to prevent 
> accidental namespace clashes.

Will fix.

> >+#define sync_cmpxchg_subword sync_cmpxchg
> >  
> 
> Ditto.

It looks like that sync_cmpxchg_subword isn't used any more.
Is it safe to eliminate sync_cmpxchg_subword?

-- 
yamahata
