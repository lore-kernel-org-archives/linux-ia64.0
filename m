From: Andreas Schwab <schwab@suse.de>
Date: Tue, 24 Jul 2001 16:37:19 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.4.7)
Message-Id: <marc-linux-ia64-105590693005898@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

David Mosberger <davidm@hpl.hp.com> writes:

|> The latest IA-64 patch is available at:
|>=20
|>  ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/
|>=20
|> in file linux-2.4.7-ia64-010723.diff*.
|>=20
|> There are no major new features in this patch but mostly bug fixes and
|> syncing up with 2.4.7.  Note that 2.4.7 introduces a somewhat
|> non-trivial change in how softirqs are handled: they are now checked
|> only as a result of a hard irq and not every time the kernel returns
|> to user mode.  While I'm not particularly happy to see such changes
|> this late in the 2.4.x series, I do believe it is safe and I have been
|> running a fairly busy machine since Saturday without any problems.  As
|> usual your mileage may vary, so test well before you ship with this
|> kernel.

Did you try out the UP kernel?  It hangs in ksoftirqd.

Andreas.

--=20
Andreas Schwab                                  "And now for something
SuSE Labs                                        completely different."
Andreas.Schwab@suse.de
SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5

