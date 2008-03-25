From: Andreas Schwab <schwab@suse.de>
Date: Tue, 25 Mar 2008 23:04:34 +0000
Subject: Re: [Patch 0/5] prepare XPC and XPNET to support SGI UV
Message-Id: <jeve3aiewt.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080325192524.343385569@attica.americas.sgi.com>
	<20080325201423.GB4446@sgi.com>
	<1FE6DD409037234FAB833C420AA843ECE9E1AB@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843ECE9E1AB@orsmsx424.amr.corp.intel.com>
	(Tony Luck's message of "Tue\, 25 Mar 2008 15\:49\:46 -0700")
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Dean Nelson <dcn@sgi.com>, jes@sgi.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

"Luck, Tony" <tony.luck@intel.com> writes:

> I think git has an option to produce its own brand of diff output
> that lists the renames without doing a full remove & add which is
> needed for patch(1) comprehensibility.  A few minutes staring at
> git documentation hasn't revealed what that option is though :-(

$ git diff -M

or "git config --global diff.renames true" to make it permanent.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
PGP key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
