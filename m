From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 13 Oct 2004 08:04:09 +0000
Subject: Re: bug in 2.6.9-rc4-mm1 ia64/mm/init.c
Message-Id: <16748.57721.66330.638048@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.33.0410121705510.31839-100000@localhost.localdomain>
In-Reply-To: <Pine.LNX.4.33.0410121705510.31839-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akepner@sgi.com
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, akpm@osdl.org, jbarnes@sgi.com

>>>>> On Tue, 12 Oct 2004 17:21:41 -0700 (PDT), <akepner@sgi.com> said:

  >> Hi Folks;

  >> Tried a kernel built with akpm's 2.6.9-rc4-mm1 patch today (using
  >> a default sn2 .config file.) It crashes on boot with:

  >> ....  SGI SAL version 3.40 Virtual mem_map starts at
  >> 0xa0007ffe85938000 Unable to handle kernel paging request at
  >> virtual address a0007ffeaf970000 swapper[0]: Oops 8813272891392
  >> [1] Modules linked in:

  >> I traced this down to a recent patch (see
  >> http://marc.theaimsgroup.com/?l=linux-mm&m9723728329408&w=2)
  >> which contains:

Why was this patch even accepted?  It seemed rather dubious to me and
I don't recall much discussion on its merits or safety.

	--david
