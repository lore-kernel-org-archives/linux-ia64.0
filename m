From: Bhaskar Chowdhury <unixbhaskar@gmail.com>
Date: Thu, 11 Mar 2021 06:36:57 +0000
Subject: Re: [PATCH] ia64: kernel: Few typos fixed in the file fsys.S
Message-Id: <YEm3ubX2Jqu49MwF@Gentoo>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="f3/NkMV43tbOhWPO"
List-Id: <linux-ia64.vger.kernel.org>
References: <20210311061058.29492-1-unixbhaskar@gmail.com>
 <e26a1461-0d05-d79c-7688-de45d285e068@infradead.org>
In-Reply-To: <e26a1461-0d05-d79c-7688-de45d285e068@infradead.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org


--f3/NkMV43tbOhWPO
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline

On 22:15 Wed 10 Mar 2021, Randy Dunlap wrote:
>On 3/10/21 10:10 PM, Bhaskar Chowdhury wrote:
>>
>> Mundane spelling fixes.
>>
>> Signed-off-by: Bhaskar Chowdhury <unixbhaskar@gmail.com>
>
>Acked-by: Randy Dunlap <rdunlap@infradead.org>
>
>but no maintainer Cc:ed to pick it up...
>
I have seen "maintainer less" files and you have pointed out that too in the
past...what do I do Randy??? Should run "git blame" to find out ,who touch the file and
include those mail??? I don't think that would be good idea.

Bemused!! Throw some light.
>> ---
>>  arch/ia64/kernel/fsys.S | 4 ++--
>>  1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/arch/ia64/kernel/fsys.S b/arch/ia64/kernel/fsys.S
>> index 0750a716adc7..2094f3249019 100644
>> --- a/arch/ia64/kernel/fsys.S
>> +++ b/arch/ia64/kernel/fsys.S
>> @@ -172,7 +172,7 @@ ENTRY(fsys_gettimeofday)
>>  	// r25 = itc_lastcycle value
>>  	// r26 = address clocksource cycle_last
>>  	// r27 = (not used)
>> -	// r28 = sequence number at the beginning of critcal section
>> +	// r28 = sequence number at the beginning of critical section
>>  	// r29 = address of itc_jitter
>>  	// r30 = time processing flags / memory address
>>  	// r31 = pointer to result
>> @@ -432,7 +432,7 @@ GLOBAL_ENTRY(fsys_bubble_down)
>>  	 *	- r29: psr
>>  	 *
>>  	 * We used to clear some PSR bits here but that requires slow
>> -	 * serialization.  Fortuntely, that isn't really necessary.
>> +	 * serialization.  Fortunately, that isn't really necessary.
>>  	 * The rationale is as follows: we used to clear bits
>>  	 * ~PSR_PRESERVED_BITS in PSR.L.  Since
>>  	 * PSR_PRESERVED_BITS==PSR.{UP,MFL,MFH,PK,DT,PP,SP,RT,IC}, we
>> --
>
>
>--
>~Randy
>

--f3/NkMV43tbOhWPO
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEnwF+nWawchZUPOuwsjqdtxFLKRUFAmBJt7kACgkQsjqdtxFL
KRWCYwf9HIUR47y/MsISUVH8Q5YejyL0nMZ6cZy/y8HALqb91B//F7rP1vDACDYe
OHEzG4qK9TuY5c0UmzpUbS2bLK46R3rIwSH2O4vTXXjHbYiR51jGTop7GxGcmz4C
5tFvRNXAyLiiFJvPpxspACKkN+DBIC06LW6F9bYPOXLEOKJD6NMQwpDCHXqna7bB
YKWS+OtCiqVQPWVZx/P5/RHNeDmrq50SbTMceYIAN/tokYCiCE8yFMcoyo3cGd0C
S/esiN+e0um44b8J3HNuIuojJI22NqKWvoMXExITsuHUa8HQwdqCJBOrNuMgFfo9
hBfUSc4s/BJZ4Z1UfRl7SnXh6+zuoA==
=idG8
-----END PGP SIGNATURE-----

--f3/NkMV43tbOhWPO--
