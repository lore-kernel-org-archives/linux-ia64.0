From: Andreas Schwab <schwab@suse.de>
Date: Mon, 05 Dec 2005 23:36:20 +0000
Subject: Re: Reading /proc/stat is slooow
Message-Id: <jeiru386bv.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <je1x0v4cpy.fsf@sykes.suse.de>
In-Reply-To: <je1x0v4cpy.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

"Luck, Tony" <tony.luck@intel.com> writes:

> How slow is sloow?

About 20 miliseconds, ten times of what I see with 2.6.13.  It appears to
be that the generation of /proc/stat doesn't scale well any more with the
number of configured CPUs (CONFIG_NR_CPUS is 512 here).  Processes that
monitor /proc/stat add a significant amount of load to the system.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
PGP key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
