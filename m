From: Andreas Schwab <schwab@suse.de>
Date: Tue, 21 Sep 2004 21:56:23 +0000
Subject: Re: [PATCH] ia32 support for NX when sigaction->sa_restorer == NULL
Message-Id: <je7jqnl20o.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <4141D3B2.2030106@intel.com>
In-Reply-To: <4141D3B2.2030106@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Arun Sharma <arun.sharma@intel.com> writes:

> When userland doesn't specify sigaction->sa_restorer, we try to put
> the restorer code on the stack. But this breaks ia32 binaries with
> non-executable stacks. We now put the restorer code on a gate page.

Does this work with nested signal handlers?

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
