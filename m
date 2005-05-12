From: Greg Edwards <edwardsg@sgi.com>
Date: Thu, 12 May 2005 16:59:23 +0000
Subject: Re: [patch] 2.6.12-rc4-mm1 missing ia64_sal_oemcall_reentrant
Message-Id: <20050512165923.GA31967@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <17027.16971.18411.788080@jaguar.mkp.net>
In-Reply-To: <17027.16971.18411.788080@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Thu, May 12, 2005 at 07:47:23AM -0400, Jes Sorensen wrote:
| Hi,
|=20
| The following patch adds the missing ia64_sal_oemcall_reentrant function
| so 2.6.12-rc4-mm1 builds and boots on the SN2 again.
|=20
| Cheers,
| Jes
|=20
| Add missing ia64_sal_oemcall_reentrant function as per the prototype
| found in include/asm-ia64/sal.h.
|=20
| Signed-off-by: Jes Sorensen <jes@trained-monkey.org>

Andrew,

The whole remove-exports-for-oem-modules.patch should be dropped.  The
SGI Altix xp* drivers use these, which just appeared with 2.6.12-rc4.

http://kernel.org/git/gitweb.cgi?p=3Dlinux/kernel/git/torvalds/linux-2.6.gi=
t;a=3Dcommit;h=B0d82bd5df874f7dadbeced1b0163473387da37c
http://kernel.org/git/gitweb.cgi?p=3Dlinux/kernel/git/torvalds/linux-2.6.gi=
t;a=3Dcommit;h=89eb8eb927e324366c3ac0458998aaf9953fc5cd
http://kernel.org/git/gitweb.cgi?p=3Dlinux/kernel/git/torvalds/linux-2.6.gi=
t;a=3Dcommit;h=A2d974da0afe659cff98913184a97c0ee686d02b

Greg
