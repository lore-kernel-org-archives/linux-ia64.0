From: Andreas Schwab <schwab@suse.de>
Date: Tue, 13 Nov 2001 10:04:13 +0000
Subject: Re: [Linux-ia64] do me a favor
Message-Id: <marc-linux-ia64-105590698805489@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805482@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805482@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

"Qiu HongBing" <qiuhb@necas.nec.co.jp> writes:

|> Excuse me,
|> But I want to avoid this problem. How to do?

Your code has never been portable.  You can't just do that.  FWIW, on a
sparc it will just crash, because unaligned accesses are strictly
forbidden.

Andreas.

--=20
Andreas Schwab                                  "And now for something
Andreas.Schwab@suse.de				completely different."
SuSE Labs, SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5

