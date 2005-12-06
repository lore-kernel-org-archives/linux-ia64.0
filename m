From: Andreas Schwab <schwab@suse.de>
Date: Tue, 06 Dec 2005 09:57:51 +0000
Subject: Re: Reading /proc/stat is slooow
Message-Id: <jevey2zgww.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <je1x0v4cpy.fsf@sykes.suse.de>
In-Reply-To: <je1x0v4cpy.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

"Luck, Tony" <tony.luck@intel.com> writes:

>>I just tried CONFIG_NR_CPUS=1024 ... and I don't see anything
>>like a 20ms delay on 2.6.15-rc5.  How many actual cpus on your
>>machine (I only have two on the machine where I tested)?
>
> Ah ... but I didn't have CONFIG_HOTPLUG_CPU set

Ah, that's the difference.  I didn't have CONFIG_HOTPLUG_CPU set in 2.6.13
either.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
PGP key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
