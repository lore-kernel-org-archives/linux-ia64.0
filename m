From: Kimio Suganuma <k-suganuma@mvj.biglobe.ne.jp>
Date: Fri, 25 Oct 2002 23:23:43 +0000
Subject: Re: [Linux-ia64] quick ia64 patch for 2.5.44 (UP only)
Message-Id: <marc-linux-ia64-105590709805255@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805243@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805243@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi,

I found that functions in timer.c and rcupdate.c are calling
tasklet_init() for all CPUs before APs start running.
I think per_cpu() cannot be used for not running CPU for ia64,
and this assumption was broken by them.

I attached args for tasklet_init() at booting and you can see
tasklet structures for CPU#0 are only valid.
Caller might be init_timers() and rcu_init().

I cannot come up with good solution for it but I think
we have to change current per_cpu implementation.
Any idea?

Thanks,
Kimi

enter tasklet_init t=E000000100000180, func=E000000004a2e340
enter tasklet_init t=A000000000008180, func=E000000004a2e340
enter tasklet_init t=A000000000008180, func=E000000004a2e340
enter tasklet_init t=A000000000008180, func=E000000004a2e340
enter tasklet_init t=A000000000008180, func=E000000004a2e340
enter tasklet_init t=A000000000008180, func=E000000004a2e340
enter tasklet_init t=A000000000008180, func=E000000004a2e340
enter tasklet_init t=A000000000008180, func=E000000004a2e340
enter tasklet_init t=A000000000008180, func=E000000004a2e340
enter tasklet_init t=A000000000008180, func=E000000004a2e340
enter tasklet_init t=A000000000008180, func=E000000004a2e340
enter tasklet_init t=A000000000008180, func=E000000004a2e340
enter tasklet_init t=A000000000008180, func=E000000004a2e340
enter tasklet_init t=A000000000008180, func=E000000004a2e340
enter tasklet_init t=A000000000008180, func=E000000004a2e340
enter tasklet_init t=A000000000008180, func=E000000004a2e340
enter tasklet_init t=E000000100000158, func=E000000004a2c100
enter tasklet_init t=A000000000008158, func=E000000004a2c100
enter tasklet_init t=A000000000008158, func=E000000004a2c100
enter tasklet_init t=A000000000008158, func=E000000004a2c100
enter tasklet_init t=A000000000008158, func=E000000004a2c100
enter tasklet_init t=A000000000008158, func=E000000004a2c100
enter tasklet_init t=A000000000008158, func=E000000004a2c100
enter tasklet_init t=A000000000008158, func=E000000004a2c100
enter tasklet_init t=A000000000008158, func=E000000004a2c100
enter tasklet_init t=A000000000008158, func=E000000004a2c100
enter tasklet_init t=A000000000008158, func=E000000004a2c100
enter tasklet_init t=A000000000008158, func=E000000004a2c100
enter tasklet_init t=A000000000008158, func=E000000004a2c100
enter tasklet_init t=A000000000008158, func=E000000004a2c100
enter tasklet_init t=A000000000008158, func=E000000004a2c100
enter tasklet_init t=A000000000008158, func=E000000004a2c100


On Fri, 25 Oct 2002 14:50:33 -0700
Kimio Suganuma <k-suganuma@mvj.biglobe.ne.jp> wrote:

> I found that tasklet_hi_action() seemed to call NULL pointer.
> So I tried to put following code (I guess this is wrong fix)
> into the function;
>=20
> 	if (t->func =3D NULL) {
> 		tasklet_unlock(t);
> 		continue;
> 	}
>=20
> And the system initialization moved on, but it hung at INIT execution.
> Anyway, I feel this problem might be related to the timer change.
>=20
> http://marc.theaimsgroup.com/?l=3Dlinux-kernel&m=103393743102152&w=3D2

--=20
Kimio Suganuma <k-suganuma@mvj.biglobe.ne.jp>


