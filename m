From: Andreas Schwab <schwab@suse.de>
Date: Fri, 28 Feb 2003 12:41:52 +0000
Subject: Re: [Linux-ia64] Port of the posix timers to IA64
Message-Id: <marc-linux-ia64-105590709805944@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805943@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805943@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Eric Piel <Eric.Piel@Bull.Net> writes:

|> Hello David,
|>=20
|> I'm working on the port of the posix timers to IA64. The first (over 4)
|> part has just been integrated in the linus tree (2.5.63) so I think you
|> can find interest in my work.=20
|> Even if it's supposed to be portable accross platforms, due to some mix
|> between long and int, it doesn't run correctly on IA64.=20
|>=20
|> Here comes my question, I'm still newbie to kernel hacking and IA64
|> compilation and I don't know how I should handle some troubles with
|> longs. In the code I have some cases like this one:
|>=20
|> long v;
|> :
|> :
|> if ( v >=3D (1 << 56)){
|> :
|> }
|>=20
|> It seems very strange for me that when compiling this part gcc considers
|> that eveything must be converted to int. I have to write 1UL instead of
|> 1 in order to obtain the correct behaviour of the code. I guess you've
|> already come along with such problem.

That's how C is working.  A type of an expression is determined
independent of the context, so the type of 1 is always int.  And shifting
by more than the width of the type is an undefined operation.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

