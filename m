From: Frank Scheiner <frank.scheiner@web.de>
Date: Tue, 10 May 2022 12:48:56 +0000
Subject: [ia64] Linux 5.17 (Debian) - Hardened Usercopy: kernel BUG at mm/usercopy.c:100
Message-Id: <b199d9f9-e3ae-df51-87b9-51202269d484@web.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org
Cc: keescook@chromium.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, debian-ia64 <debian-ia64@lists.debian.org>, Pedro Miguel Justo <pmsjt@texair.net>, Sergei Trofimovich <slyich@gmail.com>, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, Anatoly Pugachev <matorola@gmail.com>, Anton Borisov <anton.borisov@gmail.com>

Dear all,

"hardened usercopy" does not work correctly on ia64. And deactivating it
with `hardened_usercopy=off` in the kernel commandline seems to make no
real difference for specific Itanium 2 CPUs, namely:

* Madison (in rx4640 with zx1)
* Montvale (in rx2660, rx3600 and rx6600 with zx2)

...which can't successfully complete kernel boot with and w/o
`hardened_usercopy=off`.

If "hardened usercopy" is deactivated in the kernel configuration
instead it seems to allow Montvales to complete kernel boot successfully.

@Pedro: Please correct me if I understood you wrongly here.

* Montecitos (in rx2620 with zx1 and rx2660 with zx2) instead seem to
work much better (both kernel boot and userland operation) with
`hardened_usercopy=off`. They don't work w/o `hardened_usercopy=off`,
though (rx2620 needs to be checked, true for rx2660).

* Tukwilas (in rx2800 i2) seem to be not affected by this bug at all.

****

I compiled the stack traces of the machines I tested on [1].

[1]: https://pastebin.com/raw/AKfZrjWi

Please also see the originating "Re: rx2660 + debian" thread on Debian's
ia64 mailing list ([2]), and specifically [3] where Pedro and Sergei
start to dissect this problem. [4] shows that usercopy problems already
seem to exist in Linux 4.19 (for Montvales in rx2660 with zx2)!

[2]: https://lists.debian.org/debian-ia64/2022/04/threads.html

[3]: https://lists.debian.org/debian-ia64/2022/04/msg00021.html

[4]: https://lists.debian.org/debian-ia64/2022/04/msg00022.html

****

If you need more information, please let me know.

I haven't yet created a bug report on "bugzilla.kernel.org" for this.
Does this need any more information than what I just wrote above?

Cheers,
Frank
