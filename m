From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 15 Sep 2004 17:35:21 +0000
Subject: RE: INIT dumps broken?
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F020513B8@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200409141450.i8EEotfk029379@napali.hpl.hp.com>
In-Reply-To: <200409141450.i8EEotfk029379@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>BTW, I tried INIT on my box but it seemed to produce correct task
>dump to the console. I will look at it more closely...

The problem depends on which task is running on the monarch at
the time of the INIT.  Expanding the SAVE_MIN_WITH_COVER macro
in ia64_monarch_init_handler, one of the first things done is
to get "current" ... since MINSTATE_PHYS is defined, we use the
version that reads:
   mov reg=IA64_KR(Current);;dep reg=0,reg,61,3

So if our task is anything other than the initial "init_task",
we'll take a nice region 7 address from ar.k6, and convert to
physical by zapping bits [63:61].  But we happen to be running
the init_task, then ar.k6 contains a region 5 address, and we
create a garbage address by clearing the high bits, which can
lead to an MCA (if the address points somewhere bad) or to
stomping on some random place (if the address happens to be a
legal physical address).

Perhaps MIN_STATE_GET_CURRENT() needs to be smarter and handle
the region 5 case?  Or perhaps Russ will factor this into a newer
version of his percpu save area patch????

-Tony
