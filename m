From: Andreas Schwab <schwab@suse.de>
Date: Sun, 14 May 2006 21:13:40 +0000
Subject: Re: + git-hdrcleanup-vs-git-klibc-on-ia64-2.patch added to -mm tree
Message-Id: <je64k8nwcb.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1147633985.2551.14.camel@shinybook.infradead.org>
In-Reply-To: <1147633985.2551.14.camel@shinybook.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

David Woodhouse <dwmw2@infradead.org> writes:

> On Sun, 2006-05-14 at 11:01 -0700, akpm@osdl.org wrote:
>>=20
>> diff -puN include/asm-ia64/page.h~git-hdrcleanup-vs-git-klibc-on-ia64-2 =
include/asm-ia64/page.h
>> --- 25/include/asm-ia64/page.h~git-hdrcleanup-vs-git-klibc-on-ia64-2    =
Mon May 15 01:48:22 2006
>> +++ 25-akpm/include/asm-ia64/page.h     Mon May 15 01:49:38 2006
>> @@ -36,7 +36,11 @@
>>  #elif defined(CONFIG_IA64_PAGE_SIZE_64KB)
>>  # define PAGE_SHIFT    16
>>  #else
>> +#ifdef __KERNEL__
>>  # error Unsupported page size!
>> +#else
>> +#define PAGE_SHIFT     12
>> +#endif
>>  #endif
>> =20
>>  #define PAGE_SIZE              (__IA64_UL_CONST(1) << PAGE_SHIFT)
>
> Hm, same applies here as to the last one. The __KERNEL__ ifdef applies
> to the whole crap around PAGE_SHIFT _and_ PAGE_SIZE, at least.=20

Userspace should be using getpagesize() anyway.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
PGP key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
