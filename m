From: Andreas Schwab <schwab@suse.de>
Date: Wed, 02 Apr 2003 08:55:38 +0000
Subject: Re: [Linux-ia64] Re: [PATCH] sal calls w/o taking sal_lock
Message-Id: <marc-linux-ia64-105590723705384@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705378@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705378@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Keith Owens <kaos@ocs.com.au> writes:

|> I do not understand why you renamed the variables.  The SAL code is
|> enclosed in do { } while();  All variables within {} are local, they do
|> not need unique names.

Now consider what happens when you have a reference to a variable named
flags or fr in one of the macro arguments.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

