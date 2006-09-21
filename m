From: "Zou, Nanhai" <nanhai.zou@intel.com>
Date: Thu, 21 Sep 2006 03:09:57 +0000
Subject: RE: Kexec/Kdump: kdump_disable_iosapic needs CONFIG_IOSAPIC
Message-Id: <10EA09EFD8728347A513008B6B0DA77A086AC1@pdsmsx411.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060920024544.420966000@tabatha.lab.ultramonkey.org>
In-Reply-To: <20060920024544.420966000@tabatha.lab.ultramonkey.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

> -----Original Message-----
> From: linux-ia64-owner@vger.kernel.org
> [mailto:linux-ia64-owner@vger.kernel.org] On Behalf Of Horms
> Sent: 2006=C4=EA9=D4=C220=C8=D5 10:43
> To: Zou, Nanhai
> Cc: Luck, Tony; Linux-IA64; fastboot
> Subject: Kexec/Kdump: kdump_disable_iosapic needs CONFIG_IOSAPIC
>=20
> kdump_disable_iosapic() doesn't exist without CONFIG_IOSAPIC,
> calling it needs to be gaurded by a corresponding #ifdef
>=20
> This patch has been updated for IA64 Kexec/Kdump patch for 2.6.18-rc6,
> http://permalink.gmane.org/gmane.linux.ports.ia64/14988
>=20
> Signed-Off-By: Simon Horman <horms@verge.net.au>
>=20
> diff --git a/arch/ia64/kernel/crash.c b/arch/ia64/kernel/crash.c
> index ccc898c..b3f4915 100644
> --- a/arch/ia64/kernel/crash.c
> +++ b/arch/ia64/kernel/crash.c
> @@ -121,7 +121,9 @@ machine_crash_shutdown(struct pt_regs *p
>  	 * In practice this means shooting down the other cpus in
>  	 * an SMP system.
>  	 */
> +#ifdef CONFIG_IOSAPIC
>  	kexec_disable_iosapic();
> +#endif
>  #ifdef CONFIG_SMP
>  	kdump_smp_send_stop();
>  	if (kdump_wait_cpu_freeze() && kdump_on_init) 	{
> @@ -135,7 +137,9 @@ static void
>  machine_kdump_on_init(void)
>  {
>  	local_irq_disable();
> +#ifdef CONFIG_IOSAPIC
>  	kexec_disable_iosapic();
> +#endif
>  	machine_kexec(ia64_kimage);
>  }
>=20
>=20
 CONFIG_IOSAPIC is only disabled when configure kernel for simulator.=20
 So I think we do not need this #ifdef unless we are using kexec/kdump on a=
 simulator.
 Thanks
 Zou Nan hai
> --
> Horms
>   H: http://www.vergenet.net/~horms/
>   W: http://www.valinux.co.jp/en/
>=20
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
