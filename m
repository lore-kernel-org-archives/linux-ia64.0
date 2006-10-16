From: Jay Lan <jlan@engr.sgi.com>
Date: Mon, 16 Oct 2006 21:21:34 +0000
Subject: Re: A regression in IA64 kexec/kdump patch for 2.6.18?
Message-Id: <4533F7DE.4030400@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4533F2BE.3070300@engr.sgi.com>
In-Reply-To: <4533F2BE.3070300@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Jay Lan wrote:
> I ran into a problem not seen in kexec/dkump 2.6.17rc5 ia64 patch.
> The system on test was an Altix.
>=20
> The system was booted up fine; however, after loading 'kexec -p'
> and "echo c >/proc/sysrq-trigge=C5=95", the crashdump kernel would try
> to boot up and restarted the system near the end of init().
>=20
> The extraodinary message observed on the console was
>     Warning: unable to open an initial console

It failed in do_filp_open(AT_FDCWD, "/dev/console", O_RDWR, 0)
with error -2.

However, it was fine booting up as the 1st kernel.

- jay


>=20
> but the actual reboot seems to be invoked in running /sbin/init:
>     run_init_process("/sbin/init");
>=20
> The problem is 100% reproducible. I have disabled all cpus except
> cpu0 in my testing.
>=20
> Is this a known problem? Anyone else runs into this?
>=20
> Thanks,
>  - jay

