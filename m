From: Andreas Schwab <schwab@suse.de>
Date: Thu, 07 Dec 2000 15:02:06 +0000
Subject: Re: [Linux-ia64] Re: fail to mount LS120 drive
Message-Id: <marc-linux-ia64-105590678205814@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205809@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205809@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Bill Nottingham <notting@redhat.com> writes:

|> Francis Galiegue (fg@mandrakesoft.com) said:=20
|> > If not, what does a fdisk -l /dev/hdb give on an LS120 floppy? And in =
general,
|> > can LS120 floppies be partitioned? I doubt it...
|>=20
|> Yes, they can be. It's kind of odd, but it's necessary if
|> you want to use the same boot image for a disk and for
|> the CD (unless you try and fit an ia64 boot image into
|> a normal floppy size, which would be rather tight.)

What's wrong with just copying the files to the floppy?  There is no
requirement that the boot floppy has a particular size.

Andreas.

--=20
Andreas Schwab                                  "And now for something
SuSE Labs                                        completely different."
Andreas.Schwab@suse.de
SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg

