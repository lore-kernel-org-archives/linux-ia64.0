From: Jack Steiner <steiner@sgi.com>
Date: Wed, 16 Mar 2005 13:51:25 +0000
Subject: Re: Export pda_percpu?
Message-Id: <20050316135125.GA14422@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0503142038340.16107@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0503142038340.16107@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Mar 15, 2005 at 10:42:02PM -0800, Luck, Tony wrote:
> >I need cnodeid_to_nasid() to figure out which SHUB to use from mmtimer.
> >
> >
> >however cnodeid_to_nasid is defined as
> >
> >#define cnodeid_to_nasid(cnodeid)       
> >pda->cnodeid_to_nasid_table[cnodeid]
> 
> Cleaner to turn cnodeid_to_nasid() into a real function
> and export that.  Is it used in critical performance paths?
> 
> -Tony

AFAICT, none of the current uses are on performance critical pathes.
Making it a real function & exporting it is probably the best thing to
do. An alternative would be to remove cnodeid_to_nasid_table[] from
the pda & make it an exported table.


-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


