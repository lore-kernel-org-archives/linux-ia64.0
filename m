From: Keith Owens <kaos@sgi.com>
Date: Thu, 04 Mar 2004 00:22:53 +0000
Subject: Re: [patch] 2.4.25 sync unwind code with 2.6.3
Message-Id: <3276.1078359773@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <3792.1077504388@kao2.melbourne.sgi.com>
In-Reply-To: <3792.1077504388@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 3 Mar 2004 16:53:36 -0700, 
Bjorn Helgaas <bjorn.helgaas@hp.com> wrote:
>On Sunday 22 February 2004 7:46 pm, Keith Owens wrote:
>> The unwind code in 2.4.25 has drifted away from the 2.6.3 version,
>> including some missing bug fixes.
>
>> +	/* Kludge: 2.4 has down_write_trylock on semaphores but not write_trylock on
>> +	 * spinlocks, even though they are both in 2.6 and are identical.  Pretend
>> +	 * that script lock is a rw_semaphore so we can use the only 2.4 code that
>> +	 * avoids a deadlock.  KAO.
>> +	 */
>> +	if (!down_write_trylock((struct rw_semaphore *)(&script->lock)))
>> +		return NULL;
>
>Should we consider putting write_trylock() in 2.4?  It looks like
>i386, x86_64, and ppc64 already have it.

Good idea, I will do a patch once you push your bk tree.

>We also have this diff wrt. 2.6:
>
>@@ -1426,7 +1416,7 @@
> 
>              case UNW_WHERE_FR:
>                if (rval <= 5)
>-                       val = unw.preg_index[UNW_REG_F2  + (rval -  1)];
>+                       val = unw.preg_index[UNW_REG_F2  + (rval -  2)];
>                else if (rval >= 16 && rval <= 31)
>                        val = unw.preg_index[UNW_REG_F16 + (rval - 16)];
>                else {
>
>You didn't change this, but I'd feel better if I understood why
>this is different.

2.6 is correct, it should be (rval - 2) in both trees.

