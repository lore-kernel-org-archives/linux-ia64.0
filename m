From: Andreas Schwab <schwab@suse.de>
Date: Wed, 29 May 2002 08:05:24 +0000
Subject: Re: [Linux-ia64] Missing files in to-linus-2.5 BK tree; build
Message-Id: <marc-linux-ia64-105590701905611@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905608@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905608@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Peter Chubb <peter@chubb.wattle.id.au> writes:

|> Also, what did you decide to do with the scatter-gather list changes
|> (member `address' no longer exists)?   The changes to sb_iommu.c are
|> non-trivial, because it looks as if the address field was
|> overloaded...

Just look at how lib/swiotlb.c is handling this and replace all references
to the address member by zero.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

