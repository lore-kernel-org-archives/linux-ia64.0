From: Jack Steiner <steiner@sgi.com>
Date: Thu, 03 Jul 2003 13:27:36 +0000
Subject: Re: Reliably creating MCA on white box Itanium-1
Message-Id: <marc-linux-ia64-105723890315422@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105721395828393@msgid-missing>
In-Reply-To: <marc-linux-ia64-105721395828393@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> 
> Is there a way of reliably creating an MCA on a white box Itanium 1?
> B3 processors, firmware is B117A.  Failing that, what about creating an
> MCA on a white box Itanium-2?
> 
> Loading a duplicate ITC is no good, I need an MCA that actually enters
> ia64_mca_ucmc_handler in mca.c.  A working example using
> PAL_CACHE_WRITE would be nice.


Why doesnt loading a duplicate TR (not TC) work for you?  I've used that
method and found it to be reliable. 

Another way that is reliable (at least on our hardware) is to do a
load from a non-existent region 6 or 7 address. The failure modes are
different between region 6 & 7, but they both reliably produce MCAs.




-- 
Thanks

Jack Steiner    (651-683-5302)   (vnet 233-5302)      steiner@sgi.com

