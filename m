From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Wed, 06 Oct 2004 20:44:38 +0000
Subject: Re: [PATCH] 2.6 SGI Altix I/O code reorganization
Message-Id: <200410061344.38265.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F0221C989@scsmsx401.amr.corp.intel.com> <20041006195424.GF25773@cup.hp.com> <41645150.6020608@sgi.com>
In-Reply-To: <41645150.6020608@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Patrick Gefre <pfg@sgi.com>
Cc: Grant Grundler <iod00d@hp.com>, Colin Ngam <cngam@sgi.com>, "Luck, Tony" <tony.luck@intel.com>, Matthew Wilcox <matthew@wil.cx>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Wednesday, October 6, 2004 1:10 pm, Patrick Gefre wrote:
> I don't plan on respinning the large patches (unless of course they get out
> of date). It would be great to get the kill, add and qla patch in so we can
> move forward and address some these other smaller issues - rather than
> holding up the larger mods for them.

I agree, but could you please just 'vi' the 002-add-files patch and remove 
these?

 drivers/char/mmtimer.c                          |    1
 drivers/char/snsc.c                             |   25
 drivers/ide/pci/sgiioc4.c                       |   23
 drivers/serial/sn_console.c                     |  214

They should each be separate cleanup patches.  What I've done in the past is 
make copies (in this case 5) of the big patch.  Then I edit all of them to 
include only the hunks I want there.  Hopefully that'll minimize the pain of 
respinning the big patch (i.e. no respin).  Also, Tony doesn't want to deal 
with the above files, patches for them should be sent to Andrew as separate 
mails with lkml in the cc list.

Other than that, I'm all for getting these into the tree.  Thanks for all the 
work you've put into this!

Thanks,
Jesse
