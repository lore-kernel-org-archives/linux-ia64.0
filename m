From: Christoph Lameter <clameter@sgi.com>
Date: Wed, 16 Mar 2005 04:33:51 +0000
Subject: Re: Export pda_percpu?
Message-Id: <Pine.LNX.4.58.0503152032570.24646@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0503142038340.16107@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0503142038340.16107@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 15 Mar 2005, Jesse Barnes wrote:

> > What fields from the pda do you need? I think we need to eliminate the pda.
> > The pda made sense in the 2.4 kernels but not in 2.6.
> >
> > Some of the fields were recently removed as part of a SHUB2 patch.
> > The rest should be eliminated or moved.
>
> You can also create accessor functions for the fields you need and export them
> instead.  I'd rather get rid of the PDA though.

I need cnodeid_to_nasid() to figure out which SHUB to use from mmtimer.


however cnodeid_to_nasid is defined as

#define cnodeid_to_nasid(cnodeid)       pda->cnodeid_to_nasid_table[cnodeid]

