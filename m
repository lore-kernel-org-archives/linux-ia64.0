From: Andreas Schwab <schwab@suse.de>
Date: Mon, 12 May 2003 15:36:50 +0000
Subject: Re: [Linux-ia64] Re: [PATCH] Increase size of user stack
Message-Id: <marc-linux-ia64-105590723705732@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705638@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705638@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Matthew Wilcox <willy@debian.org> writes:

|> On Mon, May 12, 2003 at 10:59:38AM -0400, Martin Hicks wrote:
|> > Maybe I'm missing something, but what happens if a process is created
|> > using the default 2GB between the RBS and the stack and sometime
|> > later the process does a setrlimit to 100GB of stack.  How do the=20
|> > stack and RBS get moved around to make enough room between the two
|> > start addresses?
|>=20
|> They don't.  However, the new maximum would take effect for any newly
|> created children.

But setrlimit takes effect immediately, not only for newly created
children.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

