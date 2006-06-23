From: Andreas Schwab <schwab@suse.de>
Date: Fri, 23 Jun 2006 00:11:55 +0000
Subject: Re: patches added to release/test trees
Message-Id: <jed5d0enn8.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601270107.k0R17838011430@agluck-lia64.sc.intel.com>
In-Reply-To: <200601270107.k0R17838011430@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Keith Owens <kaos@sgi.com> writes:

> Not adding your own tags, but Linus's tags are missing from the ia64
> tree.  For some reason, just copying .git/refs/tags from the torvalds
> git tree does not work, git-branch complains about invalid objects.  I
> thought that tags were portable between trees with common ancestors.

You have only copied the references, but not the objects itself.  The
easiest way to do that is to point objects/info/alternates to your copy of
Linus' object store.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
PGP key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
