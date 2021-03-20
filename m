From: Bhaskar Chowdhury <unixbhaskar@gmail.com>
Date: Sat, 20 Mar 2021 19:22:17 +0000
Subject: Re: [PATCH] IA64: Trivial spelling fixes
Message-Id: <YFZImRuNCpQvX5Fi@Gentoo>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Kbt0JQJWvjyW9NQi"
List-Id: <linux-ia64.vger.kernel.org>
References: <20210320182347.21440-1-unixbhaskar@gmail.com>
 <a3f98ec2-46e4-c7be-5e73-96c768a35bef@physik.fu-berlin.de>
In-Reply-To: <a3f98ec2-46e4-c7be-5e73-96c768a35bef@physik.fu-berlin.de>
To: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, rdunlap@infradead.org


--Kbt0JQJWvjyW9NQi
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline

On 20:01 Sat 20 Mar 2021, John Paul Adrian Glaubitz wrote:
>Hi Bhaskar!
>
>On 3/20/21 7:23 PM, Bhaskar Chowdhury wrote:
>>
>> s/seralize/serialize/ .....three different places
>>
>> Signed-off-by: Bhaskar Chowdhury <unixbhaskar@gmail.com>
>> ---
>>  arch/ia64/kernel/pal.S | 6 +++---
>>  1 file changed, 3 insertions(+), 3 deletions(-)
>>
>> diff --git a/arch/ia64/kernel/pal.S b/arch/ia64/kernel/pal.S
>> index d3e22c018b68..06d01a070aae 100644
>> --- a/arch/ia64/kernel/pal.S
>> +++ b/arch/ia64/kernel/pal.S
>> @@ -86,7 +86,7 @@ GLOBAL_ENTRY(ia64_pal_call_static)
>>  	mov ar.pfs = loc1
>>  	mov rp = loc0
>>  	;;
>> -	srlz.d				// seralize restoration of psr.l
>> +	srlz.d				// serialize restoration of psr.l
>>  	br.ret.sptk.many b0
>>  END(ia64_pal_call_static)
>>  EXPORT_SYMBOL(ia64_pal_call_static)
>> @@ -194,7 +194,7 @@ GLOBAL_ENTRY(ia64_pal_call_phys_static)
>>  	mov rp = loc0
>>  	;;
>>  	mov ar.rsc=loc4			// restore RSE configuration
>> -	srlz.d				// seralize restoration of psr.l
>> +	srlz.d				// serialize restoration of psr.l
>>  	br.ret.sptk.many b0
>>  END(ia64_pal_call_phys_static)
>>  EXPORT_SYMBOL(ia64_pal_call_phys_static)
>> @@ -252,7 +252,7 @@ GLOBAL_ENTRY(ia64_pal_call_phys_stacked)
>>  	mov rp = loc0
>>  	;;
>>  	mov ar.rsc=loc4			// restore RSE configuration
>> -	srlz.d				// seralize restoration of psr.l
>> +	srlz.d				// serialize restoration of psr.l
>>  	br.ret.sptk.many b0
>>  END(ia64_pal_call_phys_stacked)
>>  EXPORT_SYMBOL(ia64_pal_call_phys_stacked)
>> --
>> 2.26.2
>
>Thanks for fixing this. Btw, we usually use all-lowercase letters for architecture
>names in the Linux kernel, so it should probably be "ia64: Trivial spelling fixes".
>
>And the easiest way to get those fixes into the kernel would be through Andrew Morton's
>tree.
>

I did send it to Andrew to pick up . And I took a cue from the earlier commit
messages for the architecture ...like this :

4d5a31977cc6 [IA64] reformat pal.S to fit in 80 columns, fix typos
c12fb1885787 [IA64] remove unused PAL_CALL_IC_OFF
acb15c85de57 [IA64] Do not assume output registers be reservered.

....so followed the conventions :)

>Adrian
>
>--
> .''`.  John Paul Adrian Glaubitz
>: :' :  Debian Developer - glaubitz@debian.org
>`. `'   Freie Universitaet Berlin - glaubitz@physik.fu-berlin.de
>  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913
>

--Kbt0JQJWvjyW9NQi
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEnwF+nWawchZUPOuwsjqdtxFLKRUFAmBWSJYACgkQsjqdtxFL
KRUSagf/cRC9OjWH/SmSnMozXlsUnjuxbSJPNrKuEr1oUicUlL95jN3Rjzc8re8k
0ev7t5rVEmHt29uzBtB74dHgYtWoenfMG2sphL8/jox66NJv1WHcasoI48xSInWB
QqldjN+uSCuVMh/KU9ATpg8D/Ow1VTShJJ/2ZPDMTODoue3OcjvRxa6zGIHiFFXB
TceWnd35fkh6v5xty+qLPAZl/YobKjhatSAD9HofDFQ8yG5TSqsrXWIlyrOscDT3
fzkzsH3/phVXWQ9gB2NE5LLOYBL58COFO4To7oORZVZz4iT5+o3JDPKRHDVooqyE
bwrQSP2cN2/9r5s/EXJII/6nTd+TDA==
=lRBH
-----END PGP SIGNATURE-----

--Kbt0JQJWvjyW9NQi--
