From: Andreas Schwab <schwab@suse.de>
Date: Wed, 06 Aug 2003 08:41:24 +0000
Subject: Re: PATCH: Use rm -f instead of rm
Message-Id: <marc-linux-ia64-106018161624870@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106013374422175@msgid-missing>
In-Reply-To: <marc-linux-ia64-106013374422175@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

"H. J. Lu" <hjl@lucon.org> writes:

|> "rm" may be aliased to "rm -i".

A non-interactive shell has no business of expanding aliases.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
