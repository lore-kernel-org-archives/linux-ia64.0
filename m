From: Zi Yan <ziy@nvidia.com>
Date: Thu, 23 Mar 2023 11:57:13 +0000
Subject: Re: [PATCH 02/14] arm64: drop ranges in definition of ARCH_FORCE_MAX_ORDER
Message-Id: <0A14E221-C078-4EFF-84FA-8E326685D8D5@nvidia.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=_MailMate_C0B9CB2B-1F3E-4990-8124-8C2C5E7E129D_="
List-Id: <linux-ia64.vger.kernel.org>
References: <20230323092156.2545741-1-rppt@kernel.org>
 <20230323092156.2545741-3-rppt@kernel.org> <ZBwmxbRJrF8RxZEp@arm.com>
 <ZBwr0bXdtOtKKila@kernel.org>
In-Reply-To: <ZBwr0bXdtOtKKila@kernel.org>
To: Mike Rapoport <rppt@kernel.org>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Christophe Leroy <christophe.leroy@csgroup.eu>, "David S. Miller" <davem@davemloft.net>, Dinh Nguyen <dinguyen@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Guo Ren <guoren@kernel.org>, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Max Filippov <jcmvbkbc@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Rich Felker <dalias@libc.org>, Russell King <linux@armlinux.org.uk>, Will Deacon <will@kernel.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-arm-kernel@lists.infradead.org, linux-csky@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mm@kvack.org, linux-sh@vger.kernel.org, linux-xtensa@linux-xtensa.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org

--=_MailMate_C0B9CB2B-1F3E-4990-8124-8C2C5E7E129D_=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On 23 Mar 2023, at 6:37, Mike Rapoport wrote:

> On Thu, Mar 23, 2023 at 10:15:33AM +0000, Catalin Marinas wrote:
>> On Thu, Mar 23, 2023 at 11:21:44AM +0200, Mike Rapoport wrote:
>>> From: "Mike Rapoport (IBM)" <rppt@kernel.org>
>>>
>>> It is not a good idea to change fundamental parameters of core memory=

>>> management. Having predefined ranges suggests that the values within
>>> those ranges are sensible, but one has to *really* understand
>>> implications of changing MAX_ORDER before actually amending it and
>>> ranges don't help here.
>>>
>>> Drop ranges in definition of ARCH_FORCE_MAX_ORDER
>>>
>>> Signed-off-by: Mike Rapoport (IBM) <rppt@kernel.org>
>>> ---
>>>  arch/arm64/Kconfig | 2 --
>>>  1 file changed, 2 deletions(-)
>>>
>>> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
>>> index e60baf7859d1..bab6483e4317 100644
>>> --- a/arch/arm64/Kconfig
>>> +++ b/arch/arm64/Kconfig
>>> @@ -1489,9 +1489,7 @@ config XEN
>>>  config ARCH_FORCE_MAX_ORDER
>>>  	int "Maximum zone order" if ARM64_4K_PAGES || ARM64_16K_PAGES
>>>  	default "13" if ARM64_64K_PAGES
>>> -	range 11 13 if ARM64_16K_PAGES
>>>  	default "11" if ARM64_16K_PAGES
>>> -	range 10 15 if ARM64_4K_PAGES
>>>  	default "10"
>>
>> I don't mind rewriting the help text as in the subsequent patch but I'=
d
>> keep the ranges as a safety measure. It's less wasted time explaining =
to
>> people why some random max order doesn't work. Alternatively, we can
>> drop the ranges but make this option configurable only if EXPERT.
>
> I like the EXPERT alternative more. I'll add it in v2.

I got an error report from kernel test robot, which set -1 to ARCH_FORCE_=
MAX_ORDER
via random config generator[1].

Does the EXPERT option prevent kernel test robot from generating such con=
fig?
Or we should fix random config generator?

[1] https://lore.kernel.org/linux-mm/91E887E4-0867-421F-9C75-FB9CFF15C33A=
@nvidia.com/


--
Best Regards,
Yan, Zi

--=_MailMate_C0B9CB2B-1F3E-4990-8124-8C2C5E7E129D_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----

iQJDBAEBCgAtFiEE6rR4j8RuQ2XmaZol4n+egRQHKFQFAmQcPpkPHHppeUBudmlk
aWEuY29tAAoJEOJ/noEUByhU9EYP/R6RuN1pPr5jRFyo4D+2nLzmk6uOP2JexQ6T
6fnLGGr4kraIULDhfR1OqB9bJl25FyMrS6GpsJckpg7FQkXxffvVmdAFFv8MHhyF
/Yag0WuKNuozliOMeL2WW4qLrlk+wS41ipvi5s1vqJQKjfvjB4bNrL4ELh+wAso3
6mVTpnad6XsJJxZ70i2QMD0hOOA/GnSTyFw7/h4Wm0BS+sTV3amC7DvIE3Tx1XVG
uFxBHjOsSe0UXUuo+Z5ZQZSqdkmfvzzY35/NzOBYx1v0aVWUueXsdTLFrukWEPJu
AQA1NIqcxz+p7+OxgNrNiyGQIr9aroJb5jgfjenXjcat8lsiTFqW6lZmKviaQ+w+
Bpur3EgYyQOiZFf6ox99WXbJONqPhSwVG36+Vsu9ACj/oCzmBNwlUtOuQn62Q50M
Ct2k4j/UmhDPBCXZpHWLwqGTwhvqs3uSIOMPqZe0qaXAd6MJw1sPqa8h6MV5+Vf9
mWBApZod3ekSrRR8GKuKortn8Wm0Lh/KtdxAn5vWRV6UKq3wgSJTHwPwJjKVsa/Q
q02bSlYj3SgmnbkFbHK4S0x6Bf8p1R6XreCW5nLnv5NuPiKeG9yLkqOJk5d7uqmY
Z8gVdSyn1DAQ98Qs+VXDP6uYrt0Sq3/uqEdHgwWSYaCA0vmzzlQoRcheTh+n9Cq2
F6T7/BJg
=WfgP
-----END PGP SIGNATURE-----

--=_MailMate_C0B9CB2B-1F3E-4990-8124-8C2C5E7E129D_=--
