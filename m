From: Valdis.Kletnieks@vt.edu
Date: Sat, 09 Jul 2016 06:17:17 +0000
Subject: Re: [kernel-hardening] Re: [PATCH 9/9] mm: SLUB hardened usercopy support
Message-Id: <24451.1468045037@turing-police.cc.vt.edu>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="==_Exmh_1468045037_2093P"
List-Id: <linux-ia64.vger.kernel.org>
References: <577f7e55.4668420a.84f17.5cb9SMTPIN_ADDED_MISSING@mx.google.com> <alpine.DEB.2.20.1607080844370.3379@east.gentwo.org> <CAGXu5jKE=h32tHVLsDeaPN1GfC+BB3YbFvC+5TE5TK1oR-xU3A@mail.gmail.com> <alpine.DEB.2.20.1607081119170.6192@east.gentwo.org> <CAGXu5j+UdkQA+k39GNLe5CwBPVD5ZbRGTCQLqS8VF=kWx+PtsQ@mail.gmail.com> <CAGXu5jKxw3RxWNKLX4XVCwJ6x_zA=_RwiU9jLDm2+VRO79G7+w@mail.gmail.com>
 <57809299.84b3370a.5390c.ffff9e58SMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <57809299.84b3370a.5390c.ffff9e58SMTPIN_ADDED_BROKEN@mx.google.com>
To: kernel-hardening@lists.openwall.com
Cc: Kees Cook <keescook@chromium.org>, Christoph Lameter <cl@linux.com>, Jan Kara <jack@suse.cz>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Linux-MM <linux-mm@kvack.org>, sparclinux <sparclinux@vger.kernel.org>, linux-ia64@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, linux-arch <linux-arch@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, Russell King <linux@armlinux.org.uk>, PaX Team <pageexec@freemail.hu>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Fenghua Yu <fenghua.yu@intel.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Tony Luck <tony.luck@intel.com>, Andy Lutomirski <luto@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, Brad Spengler <spender@grsecurity.net>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, LKML <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, Case y Sc hauf ler <casey@schaufler-ca.com>, Andrew Morton <akpm@linux-foundation.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "David S. Miller" <davem@davemloft.net>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

--==_Exmh_1468045037_2093P
Content-Type: text/plain; charset=us-ascii

On Sat, 09 Jul 2016 15:58:20 +1000, Michael Ellerman said:

> I then get two hits, which may or may not be valid:
>
> [    2.309556] usercopy: kernel memory overwrite attempt detected to d000000003510028 (kernfs_node_cache) (64 bytes)
> [    2.309995] CPU: 7 PID: 2241 Comm: wait-for-root Not tainted 4.7.0-rc3-00099-g97872fc89d41 #64
> [    2.310480] Call Trace:
> [    2.310556] [c0000001f4773bf0] [c0000000009bdbe8] dump_stack+0xb0/0xf0 (unreliable)
> [    2.311016] [c0000001f4773c30] [c00000000029cf44] __check_object_size+0x74/0x320
> [    2.311472] [c0000001f4773cb0] [c00000000005d4d0] copy_from_user+0x60/0xd4
> [    2.311873] [c0000001f4773cf0] [c0000000008b38f4] __get_filter+0x74/0x160
> [    2.312230] [c0000001f4773d30] [c0000000008b408c] sk_attach_filter+0x2c/0xc0
> [    2.312596] [c0000001f4773d60] [c000000000871c34] sock_setsockopt+0x954/0xc00
> [    2.313021] [c0000001f4773dd0] [c00000000086ac44] SyS_setsockopt+0x134/0x150
> [    2.313380] [c0000001f4773e30] [c000000000009260] system_call+0x38/0x108

Yeah, 'ping' dies with a similar traceback going to rawv6_setsockopt(),
and 'trinity' dies a horrid death during initialization because it creates
some sctp sockets to fool around with.  The problem in all these cases is that
setsockopt uses copy_from_user() to pull in the option value, and the allocation
isn't tagged with USERCOPY to whitelist it.

Unfortunately, I haven't been able to track down where in net/ the memory is
allocated, nor is there any good hint in the grsecurity patch that I can find
where they do the tagging.

And the fact that so far, I'm only had ping and trinity killed in setsockopt()
hints that *most* setsockopt() calls must be going through a code path that
does allocate suitable memory, and these two have different paths.  I can't
believe they're the only two binaries that call setsockopt().....

Just saw your second mail, now I'm wondering why *my* laptop doesn't die a
horrid death when systemd starts up.  Mine is
systemd-230-3.gitea68351.fc25.x86_64 - maybe there's something
release-dependent going on?


--==_Exmh_1468045037_2093P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBV4CW7QdmEQWDXROgAQLUag/+Iz4v6YO8so3dhT9TGomJm5+Bo2odFdZ1
/d6anx4xLfnrK4GDl86bGR8mz44oNOBd1yBIAXqB1VAcEgCGwtg80TCrU5H88DSv
gW6b5q9Vs+zhisKFu+x14yrjnb6hM7Y5In5FNCe5R+TJwyyjxFGs+qVfaMsEuXDi
39Xb1SWwkP7TRF9T7xRBpHmV+MMbEae3SH7uoc428Ovgskm+3nZI3IrO+p2ffFkH
6U5dD0s4dUQrH5EsO0+IkzdyVdL8VRDgmy194qRo9pJ0/zIXqSpvV2KM46CvfX9V
pY32EsB0yRIsZZMiOTgIQMWJA0lg/+p/6CmJ1O26sYbJ0ibSxyTgQVeNH8U+odAJ
dckvMyKDZ9LEqw0PUFMByABJ8NY8O5Y0U0+Bhk48We/MZlrtu/kX4469rYplsEzw
cbCH8xOngJyUw/jrj0XDoNp0oB+eVH59StP0iXsDzGvoj3sNlPwlI2Q027THJzD0
P9XNgPzpQjV2txNYZ5veGY78yaP86JlikhO3zrv9DO+yXDV3F7vOMeLs8yB8p+D9
I0mhBtNaB53vG2LYh2ycqKYDsFw3pALfi1Boz58kZ7xcvsSDQDf8cIXq/9lpeRbY
hHCkLjQlAbNg2N3nIdE0/Vl+9zzo3XP4n8IugFwyJCPkufCfKpfGdhZpZKFexHsV
vS7IPe5s4BQ=
=RRF1
-----END PGP SIGNATURE-----

--==_Exmh_1468045037_2093P--
