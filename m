From: Andreas Schwab <schwab@suse.de>
Date: Mon, 22 Jul 2002 12:34:30 +0000
Subject: Re: [Linux-ia64] kernel update (relative to v2.4.18)
Message-Id: <marc-linux-ia64-105590701905799@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Keith Owens <kaos@ocs.com.au> writes:

|> On Mon, 22 Jul 2002 13:54:36 +0200,=20
|> Andreas Schwab <schwab@suse.de> wrote:
|> >Why are you explicitly disabling CONFIG_BLK_DEV_LOOP, CONFIG_BLK_DEV_NBD
|> >and CONFIG_BLK_DEV_RAM?
|>=20
|> make xconfig was complaining that those variables appeared elsewhere in
|> the menu but were not being set in one branch of the menu tree.
|> Explicitly setting them to "n" removes the xconfig warnings, the
|> variables were already implicitly set to n.

Where?  Why should an Itanium configuration not be able to use a loop
device or a ram disk???

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

