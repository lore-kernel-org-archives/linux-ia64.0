From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Thu, 07 Oct 2004 16:52:02 +0000
Subject: Re: [PATCH] 2.6 SGI Altix I/O code reorganization
Message-Id: <200410070952.02291.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F0221C989@scsmsx401.amr.corp.intel.com> <200410061344.38265.jbarnes@engr.sgi.com> <41655A91.1010307@sgi.com>
In-Reply-To: <41655A91.1010307@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Patrick Gefre <pfg@sgi.com>
Cc: Grant Grundler <iod00d@hp.com>, Colin Ngam <cngam@sgi.com>, "Luck, Tony" <tony.luck@intel.com>, Matthew Wilcox <matthew@wil.cx>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Thursday, October 7, 2004 8:02 am, Patrick Gefre wrote:
> > They should each be separate cleanup patches.  What I've done in the past
> > is make copies (in this case 5) of the big patch.  Then I edit all of
> > them to include only the hunks I want there.  Hopefully that'll minimize
> > the pain of respinning the big patch (i.e. no respin).  Also, Tony
> > doesn't want to deal with the above files, patches for them should be
> > sent to Andrew as separate mails with lkml in the cc list.
>
> These are not cleanup.
>
> The mmtimer code and sn_console include a file that doesn't exist anymore
> in the directory included - it's moved to somewhere else in the 002 patch.
>
> snsc.c, sgiioc4.c have changes for things that won't exist after this patch
> is applied.

Yeah, sorry, I shouldn't have said cleanup, fixup is better.  Anyway, they 
need to be separate since they'll be going into the tree via Andrew not Tony.

Thanks,
Jesse
