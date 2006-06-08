From: Andreas Schwab <schwab@suse.de>
Date: Thu, 08 Jun 2006 08:19:19 +0000
Subject: Re: Question about the segment [[ 60000fff80000000-60000fff80004000 rw-p 0000000000000000 00:00 0 ]]
Message-Id: <jepshk3vqw.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2A0EE673@scsmsx411.amr.corp.intel.com>
In-Reply-To: <617E1C2C70743745A92448908E030B2A0EE673@scsmsx411.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

"vamsi krishna" <vamsi.krishnak@gmail.com> writes:

> Looks like If I dont overwrite the RSE backing store fclose on my open
> files seem to crash when I restore my program.

You also need to make sure that all function descriptors end up at the
very same address.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
PGP key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
