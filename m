From: Andreas Schwab <schwab@suse.de>
Date: Tue, 13 Dec 2005 15:10:15 +0000
Subject: Re: [PATCH]: Prevent sn2 ptc code from executing on all ia64 subarches
Message-Id: <jevext3ueg.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051121180016.24224.2378.sendpatchset@prarit.boston.redhat.com>
In-Reply-To: <20051121180016.24224.2378.sendpatchset@prarit.boston.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Prarit Bhargava <prarit@sgi.com> writes:

> Andreas -- I just recieved the following from a PPC engineer at IBM:
>
> "I don't think it is possible to build a ppc kernel with just
> CONFIG_PPC_MULTIPLATFORM set. You'll need to "choose" another compile
> option such as "cell" or "iseries" or "pseries" or somesuch (from
> arch/powerpc/platforms/). Check arch/powerpc/configs for the relevant
> defconfigs."
>
> ... so it looks like this is currently limited to ia64 ...

CONFIG_PPC_MULTIPLATFORM is just a meta config that enables you to
configure for multiple platforms.  In this way it is perfectly comparable
to CONFIG_IA64_GENERIC.  The only difference is that CONFIG_IA64_GENERIC
enables _all_ platforms with one option, whereas CONFIG_PPC_MULTIPLATFORM
still lets you chose which one of the platforms to support at all, but you
can chose to support more than one in a single kernel.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
PGP key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
