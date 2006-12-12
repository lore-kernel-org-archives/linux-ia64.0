From: Christoph Lameter <clameter@sgi.com>
Date: Tue, 12 Dec 2006 17:20:39 +0000
Subject: Re: test_and_set_bit implementation
Message-Id: <Pine.LNX.4.64.0612120917530.8557@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <457EC42C.90002@bull.net>
In-Reply-To: <457EC42C.90002@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 12 Dec 2006, Zoltan Menyhart wrote:

> Let's assume the bit test & set is already set, why is then the
> cmpxchg_acq() executed? Cannot we just return, e.g. like this?
> 
>        do {
>                old = *m;
> 		if (old & bit)
> 			return 1;
>                new = old | bit;
>        } while (cmpxchg_acq(m, old, new) != old);


I think this will work. However, usually you execute bit test and test 
because the bit is not set and you want to set it. This change would 
optimize a rarely taken path. Probably not worth it.


