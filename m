From: Andreas Schwab <schwab@suse.de>
Date: Tue, 11 May 2004 16:24:22 +0000
Subject: Re: [PATCH] set EXEC_PAGESIZE to PAGE_SIZE
Message-Id: <jen04fdj9l.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040511145923.GC23495@sgi.com>
In-Reply-To: <20040511145923.GC23495@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

edwardsg@sgi.com (Greg Edwards) writes:

> The number of pages allocated for the gid_t * blocks[] array in the
> group_info struct is calculated from EXEC_PAGESIZE.  This is used when
> the number of groups goes above 32.  On ia64, this is currently
> hard-coded at 65536, which results in only a 1/4 of the required pages
> being allocated on a 16k page size kernel.  A setgroups() call with a
> gidsetsize of 65536 will end up tromping on memory.  Patch below sets
> EXEC_PAGESIZE to PAGE_SIZE.

IMHO the real bug is that EXEC_PAGESIZE is used in the first place.
EXEC_PAGESIZE is supposed to be the biggest page size supported by any
executable, thus is should always be the max of all possible page sizes.
It has no relation to the actual page size of the running kernel.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
