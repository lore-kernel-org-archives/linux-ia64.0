From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Mon, 30 Nov 2020 12:27:26 +0000
Subject: Re: vmlinux link failure on ia64 with zstd
Message-Id: <067e9ef5-7555-6f8d-f744-e6400184d6ef@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <f0a93b2d435252b3878ce821142677754f5e434c.camel@decadent.org.uk>
 <6A76267A-6B60-4428-94DF-E05706EB85FB@fb.com>
 <CAK7LNAToB3n9Y9OPXR55VKbDAkYgm1kUDO8gUu0Ak_+=6AhzCw@mail.gmail.com>
In-Reply-To: <CAK7LNAToB3n9Y9OPXR55VKbDAkYgm1kUDO8gUu0Ak_+=6AhzCw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masahiro Yamada <masahiroy@kernel.org>, Nick Terrell <terrelln@fb.com>
Cc: Ben Hutchings <ben@decadent.org.uk>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Tony Luck <tony.luck@intel.com>

Hi Masahiro!

On 9/15/20 8:48 AM, Masahiro Yamada wrote:
> dc35da16a2e2 is more than two years old (i.e. v4.17)
> 
> Are we discussing a long-standing issue
> or something that arose recently?

Kernels up to 5.7.0 built fine on ia64 in Debian [1], but I assume that zstd was
only recently enabled in Debian's standard kernel.

Adrian

> [1] https://buildd.debian.org/status/logs.php?pkg=linux&arch=ia64

-- 
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer - glaubitz@debian.org
`. `'   Freie Universitaet Berlin - glaubitz@physik.fu-berlin.de
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913
