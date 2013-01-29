From: Borislav Petkov <bp@alien8.de>
Date: Tue, 29 Jan 2013 13:59:46 +0000
Subject: Re: [PATCH v5 14/20] scripts/gdb: Add internal helper and convenience function to retrieve thread_in
Message-Id: <20130129135946.GG14302@pd.tnic>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1359463075.git.jan.kiszka@siemens.com>
 <c4fb2b8d82932f2e86956bd0bd08caf15855b652.1359463075.git.jan.kiszka@siemens.com>
In-Reply-To: <c4fb2b8d82932f2e86956bd0bd08caf15855b652.1359463075.git.jan.kiszka@siemens.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: Jan Kiszka <jan.kiszka@siemens.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Jason Wessel <jason.wessel@windriver.com>, kgdb-bugreport@lists.sourceforge.net, Andi Kleen <andi@firstfloor.org>, Tom Tromey <tromey@redhat.com>, Ben Widawsky <ben@bwidawsk.net>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

On Tue, Jan 29, 2013 at 01:37:57PM +0100, Jan Kiszka wrote:
> Add the internal helper get_thread_info that calculated the thread_info
> from a given task variable. Also export this service as a convenience
> function.
>=20
> Note: ia64 version is untested.
>=20
> CC: Tony Luck <tony.luck@intel.com>
> CC: Fenghua Yu <fenghua.yu@intel.com>
> CC: linux-ia64@vger.kernel.org
> Signed-off-by: Jan Kiszka <jan.kiszka@siemens.com>
> ---

[ =E2=80=A6 ]

> +class LxThreadInfoFunc (gdb.Function):
> +	# Calculate Linux thread_info from task variable.
> +	__doc__ =3D "Calculate Linux thread_info from task variable.\n" \
> +		  "\n" \
> +		  "$lx_thread_info(TASK): Given TASK, return the corresponding thread_=
info\n" \
> +		  "variable."
> +
> +	def __init__(self):
> +		super(LxThreadInfoFunc, self).__init__("lx_thread_info")
> +
> +	def invoke(self, task):
> +		return get_thread_info(task)
> +
> +LxThreadInfoFunc()

Nice, you can plug commands into one-another:

(gdb) p $lx_thread_info($lx_current())
$12 =3D {task =3D 0xffffffff81a14440, exec_domain =3D 0xffffffff81a21e00, f=
lags =3D 0, status =3D 0, cpu =3D 0,=20
  preempt_count =3D 1, addr_limit =3D {seg =3D 18446744073709551615}, resta=
rt_block =3D {
    fn =3D 0xffffffff81054cd0 <do_no_restart_syscall>, {futex =3D {uaddr =
=3D 0x0, val =3D 0, flags =3D 0, bitset =3D 0,=20
        time =3D 0, uaddr2 =3D 0x0}, nanosleep =3D {clockid =3D 0, rmtp =3D=
 0x0, compat_rmtp =3D 0x0, expires =3D 0},=20
      poll =3D {ufds =3D 0x0, nfds =3D 0, has_timeout =3D 0, tv_sec =3D 0, =
tv_nsec =3D 0}}}, sysenter_return =3D 0x0,=20
  sig_on_uaccess_error =3D 0, uaccess_err =3D 0}

--=20
Regards/Gruss,
    Boris.

Sent from a fat crate under my desk. Formatting is fine.
--
