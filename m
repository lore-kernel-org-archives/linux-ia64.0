From: Don Dugger <n0ano@valinux.com>
Date: Thu, 19 Apr 2001 14:21:03 +0000
Subject: Re: [Linux-ia64] Re: Detecting SMP in user space
Message-Id: <marc-linux-ia64-105590693005431@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005429@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005429@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Andreas-

On my system the boot messages are copied into `/var/log/messages'
so you can always go there even if the boot log is cleared.

On Thu, Apr 19, 2001 at 02:56:17PM +0200, Andreas Schwab wrote:
> Bill Nottingham <notting@redhat.com> writes:
>=20
> |> Andreas Schwab (schwab@suse.de) said:=20
> |> > |> How about simply running 'top' or a 'dmesg | grep CPU'?
> |> >=20
> |> > As I already said, I'm running a UP kernel, thus top only ever sees =
one
> |> > CPU.  The latter fails if the boot messages have already been cleare=
d from
> |> > the kernel log.
> |>=20
> |> I believe the ACPI boot messages on ia64 tell you how many processors
> |> it found.
>=20
> How can I get at the ACPI boot messages if the kernel log is already
> cleared?
>=20
> Andreas.
>=20
> --=20
> Andreas Schwab                                  "And now for something
> SuSE Labs                                        completely different."
> Andreas.Schwab@suse.de
> SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg
> Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
>=20
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

--=20
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@valinux.com
Ph: 303/938-9838

