From: Andreas Schwab <schwab@suse.de>
Date: Thu, 25 Jan 2001 11:20:55 +0000
Subject: Re: [Linux-ia64] That getpagesize() problem again!
Message-Id: <marc-linux-ia64-105590693005097@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005096@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005096@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Francis Galiegue <fg@mandrakesoft.com> writes:

|> When trying to install only two packages via RPM in a chroot, this is wh=
at I
|> get:
|>=20
|> rpm: ../sysdeps/unix/sysv/linux/ia64/getpagesize.c:36: __getpagesize: As=
sertion
|> `_dl_pagesize !=3D 0'
|> failed.
|>=20
|> Then, abort and core dump.
|>=20
|> What I'd like to know is why, in the glibc file mentioned in the error,
|> __getpagesize is defined as such:
|>=20
|> int
|> __getpagesize ()
|> {
|>   assert (_dl_pagesize !=3D 0);
|>   return _dl_pagesize;
|> }
|>=20
|> (that's glibc 2.2.1, but 2.2 exhibits the same behaviour)
|>=20
|> This looks all the more strange that you can define the page size during=
 kernel
|> compile! A sample test program which I made using the getpagesize() sysc=
all
|> yields the correct value, though...

If the getpagesize syscall works, then your kernel is too old.

|> What should I do?

You need to run kernel 2.4.0-test9 with the 001030 patch or later.
Earlier versions didn't pass AT_PAGESZ in all cases.

Andreas.

--=20
Andreas Schwab                                  "And now for something
SuSE Labs                                        completely different."
Andreas.Schwab@suse.de
SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg

