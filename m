From: Andreas Schwab <schwab@suse.de>
Date: Tue, 26 Jun 2001 17:15:16 +0000
Subject: Re: [Linux-ia64] Re: volatile unsigned long cpu_online_map vs unsigned long cpu_online_map
Message-Id: <marc-linux-ia64-105590693005777@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005772@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005772@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Bill Nottingham <notting@redhat.com> writes:

|> Andreas Schwab (schwab@suse.de) said:=20
|> > |> Also, shoudn't it be extern in at least one of setup.c/smpboot.c?
|> >=20
|> > No.  The definition in setup.c is guarded by CONFIG_SMP, and smpboot.c=
 is
|> > not use on non-SMP.
|>=20
|> But then on a SMP kernel you have two definitions of the same
|> symbol, yes?

Yes, you are right, I got the logic wrong.

Andreas.

--=20
Andreas Schwab                                  "And now for something
SuSE Labs                                        completely different."
Andreas.Schwab@suse.de
SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5

