From: Tony Luck <tony.luck@intel.com>
Date: Mon, 04 Oct 2010 18:52:37 +0000
Subject: Re: [RFC][PATCH] [ia64] Raise minimum binutils version and remove
Message-Id: <AANLkTi=jQPFkNhXcw2Dp5QWN9Hjg9gk3UZagtRNDn5P3@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1286158823.3916.227.camel@localhost>
In-Reply-To: <1286158823.3916.227.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Sun, Oct 3, 2010 at 7:20 PM, Ben Hutchings <ben@decadent.org.uk> wrote:
> diff --git a/Documentation/Changes b/Documentation/Changes
> index 4fb88f1..23fc499 100644
> --- a/Documentation/Changes
> +++ b/Documentation/Changes
> @@ -30,7 +30,7 @@ isdn4k-utils.
>
> =A0o =A0Gnu C =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A03.2 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 # gcc --version
> =A0o =A0Gnu make =A0 =A0 =A0 =A0 =A0 =A0 =A0 3.80 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0# make --version
> -o =A0binutils =A0 =A0 =A0 =A0 =A0 =A0 =A0 2.12 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0# ld -v
> +o =A0binutils =A0 =A0 =A0 =A0 =A0 =A0 =A0 2.12 (2.16 for ia64) =A0 =A0# =
ld -v
> =A0o =A0util-linux =A0 =A0 =A0 =A0 =A0 =A0 2.10o =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 # fdformat --version
> =A0o =A0module-init-tools =A0 =A0 =A00.9.10 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0# depmod -V
> =A0o =A0e2fsprogs =A0 =A0 =A0 =A0 =A0 =A0 =A01.41.4 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0# e2fsck -V

Won't this file become a complete mess if each architecture starts
specifying its own version for each of the tools?  Is it likely that
all the others will follow ia64's bold lead in moving past 2.12
for binutils?

Overall this patch looks to be a good idea (oldest binutils on any
of my systems is 2.17) ... so clearing out all the ancient tests
for long-fixed bugs is nice.  But I worry about being the trend
setter here.

-Tony
