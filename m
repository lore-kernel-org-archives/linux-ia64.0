From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 16 Mar 2005 06:42:02 +0000
Subject: RE: Export pda_percpu?
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F03164382@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0503142038340.16107@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0503142038340.16107@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>I need cnodeid_to_nasid() to figure out which SHUB to use from mmtimer.
>
>
>however cnodeid_to_nasid is defined as
>
>#define cnodeid_to_nasid(cnodeid)       
>pda->cnodeid_to_nasid_table[cnodeid]

Cleaner to turn cnodeid_to_nasid() into a real function
and export that.  Is it used in critical performance paths?

-Tony
