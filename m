From: Andreas Schwab <schwab@suse.de>
Date: Thu, 07 Dec 2000 16:52:00 +0000
Subject: Re: [Linux-ia64] Re: Re: fail to mount LS120 drive
Message-Id: <marc-linux-ia64-105590678205816@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205815@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205815@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Bill Nottingham <notting@redhat.com> writes:

|> Andreas Schwab (schwab@suse.de) said:=20
|> > |> Yes, they can be. It's kind of odd, but it's necessary if
|> > |> you want to use the same boot image for a disk and for
|> > |> the CD (unless you try and fit an ia64 boot image into
|> > |> a normal floppy size, which would be rather tight.)
|> >=20
|> > What's wrong with just copying the files to the floppy?  There is no
|> > requirement that the boot floppy has a particular size.
|>=20
|> True. It's just that if you try to use anything greater than 2.88MB
|> for a CDROM boot image, it has to be partitioned

There is no problem to make a CDROM boot image of any size, for the ia64
at least.  Just specify -no-emul-boot when creating the CD image.

Andreas.

--=20
Andreas Schwab                                  "And now for something
SuSE Labs                                        completely different."
Andreas.Schwab@suse.de
SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg

