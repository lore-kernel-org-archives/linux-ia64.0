From: Andreas Schwab <schwab@suse.de>
Date: Sun, 22 Feb 2004 13:58:34 +0000
Subject: Re: Oops in pdflush
Message-Id: <je65dzi5bp.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <je4qtl7u44.fsf@sykes.suse.de>
In-Reply-To: <je4qtl7u44.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Keith Owens <kaos@sgi.com> writes:

> Can you try running with the kdb patch to see if that gives a better
> backtrace for the oops?

kdb couldn't do it better.

[2]kdb> bt
Stack traceback for pid 21693
0xe00000002faf0000    21693        1  1    2   R  0xe00000002faf04b0 *pdflu=
sh
0xa0000001003ff290 kdba_main_loop+0x150
        args (0x5, 0x5, 0x20000000030, 0x4, 0xe00000002faf6640)
        kernel 0xa0000001003ff140 0xa0000001003ff2c0
0xa000000100283e60 kdb+0x820
        args (0x5, 0x20000000030, 0xe00000002faf6640, 0xa00000010082bbd0, 0=
xa000000100887a84)
        kernel 0xa000000100283640 0xa000000100284bc0
0xa0000001000393c0 die+0x1e0
        args (0xe00000002faf64b0, 0xe00000002faf6640, 0x20000000030, 0xa000=
00010071fa80, 0xa000000100039570)
        kernel 0xa0000001000391e0 0xa000000100039400
0xa000000100039570 ia64_fault+0x110
        args (0x18, 0x20000000030, 0xe000000004c86b60, 0x3, 0xe00000002faf6=
640)
        kernel 0xa000000100039460 0xa00000010003a4e0
0xa00000010000d640 ia64_leave_kernel
        args (0x18, 0x20000000030, 0xe000000004c86b60, 0x3, 0xe00000002faf6=
640)
        kernel 0xa00000010000d640 0xa00000010000d8a0
0xe00000002faf5f00 - No name.  May be an area that has no unwind data

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
