From: Andreas Schwab <schwab@suse.de>
Date: Thu, 02 May 2002 16:42:10 +0000
Subject: Re: [Linux-ia64] readdir(3) return and error code
Message-Id: <marc-linux-ia64-105590701905546@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905544@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905544@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Jacky Malcles <Jacky.Malcles@bull.net> writes:

|> While doing some testing I came across something that is odd for me,
|> according to readdir(3) EBADF is returned for an invalid argument.

The POSIX standard says:

    The readdir() function may fail if:

    [EBADF] The dirp argument does not refer to an open directory stream.

(Note that readdir() is not _required_ to fail in this case.)

|> I'm doing a basic call with a bad argument i,e:
|>     struct dirent *dptr;
|>     dptr =3D readdir("test_dir_1");

This is complete garbage, so you cannot expect anything usefull according
to the GIGO priciple.  A string is not remotely anything matching DIR*,
all bets are off.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE GmbH, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

