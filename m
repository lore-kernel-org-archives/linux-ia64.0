From: Andreas Schwab <schwab@suse.de>
Date: Tue, 10 Apr 2001 09:55:00 +0000
Subject: Re: [Linux-ia64] strace / ptrace_offsets.h
Message-Id: <marc-linux-ia64-105590693005386@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005384@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005384@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Gustavo Niemeyer <niemeyer@conectiva.com> writes:

|> I've just found this message from Uros in the mailing list
|> archive:
|>=20
|> > I am trying to compile strace under 2.4.0-test6 and I missing symbols
|> > for PT_K_B0, PT_K_AR_PFS, PT_K_AR_UNAT, PT_K_AR_RNAT, PT_K_AR_BSPSTORE,
|> > PT_K_PR and PT_CR_IFS.  I have
|> > sucessfully compiled the same source under 2.3.99-pre6 kernel headers.
|> >=20
|> > Symbol PT_CR_IFS was replaced with PT_CFM; this is a problem with stra=
ce
|> > source.  However, the other symbols disappeared from ptrace_offsets.h.
|> > I don't recall any patches against ptrace interface lately.  Is this a
|> > lossage in kernel headers?
|>=20
|> Unfortunately, I haven't found any answeres to this post.
|>=20
|> This problem seems to be back with strace 4.3 and kernel 2.4.3. In this
|> case, which one should be fixed??

Use the strace source from the ia64_0 branch on
cvs.strace.sourceforge.net.

Andreas.

--=20
Andreas Schwab                                  "And now for something
SuSE Labs                                        completely different."
Andreas.Schwab@suse.de
SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5

