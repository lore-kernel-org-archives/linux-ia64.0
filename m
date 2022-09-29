From: Nicolas Schier <nicolas@fjasle.eu>
Date: Thu, 29 Sep 2022 19:44:36 +0000
Subject: Re: [PATCH] ia64: simplify esi object addition in Makefile
Message-Id: <YzX1pC8KpAwLFzfq@fjasle.eu>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Tq5f2PmMQquE+b+1"
List-Id: <linux-ia64.vger.kernel.org>
References: <20220929181715.2504087-1-masahiroy@kernel.org>
In-Reply-To: <20220929181715.2504087-1-masahiroy@kernel.org>
To: Masahiro Yamada <masahiroy@kernel.org>
Cc: linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org


--Tq5f2PmMQquE+b+1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Sep 30, 2022 at 03:17:15AM +0900, Masahiro Yamada wrote:
> CONFIG_IA64_ESI is a bool option. I do not know why the Makefile was
> written like this, but this should not have any functional change.
>=20
> Signed-off-by: Masahiro Yamada <masahiroy@kernel.org>
> ---
>=20
>  arch/ia64/kernel/Makefile | 5 +----
>  1 file changed, 1 insertion(+), 4 deletions(-)
>=20
> diff --git a/arch/ia64/kernel/Makefile b/arch/ia64/kernel/Makefile
> index 4a1fcb121dda..ae9ff07de4ab 100644
> --- a/arch/ia64/kernel/Makefile
> +++ b/arch/ia64/kernel/Makefile
> @@ -34,10 +34,7 @@ mca_recovery-y			+=3D mca_drv.o mca_drv_asm.o
>  obj-$(CONFIG_IA64_MC_ERR_INJECT)+=3D err_inject.o
>  obj-$(CONFIG_STACKTRACE)	+=3D stacktrace.o
> =20
> -obj-$(CONFIG_IA64_ESI)		+=3D esi.o
> -ifneq ($(CONFIG_IA64_ESI),)
> -obj-y				+=3D esi_stub.o	# must be in kernel proper
> -endif
> +obj-$(CONFIG_IA64_ESI)		+=3D esi.o esi_stub.o # must be in kernel proper
>  obj-$(CONFIG_INTEL_IOMMU)	+=3D pci-dma.o
> =20
>  obj-$(CONFIG_ELF_CORE)		+=3D elfcore.o
> --=20
> 2.34.1

Reviewed-by: Nicolas Schier <nicolas@fjasle.eu>


--Tq5f2PmMQquE+b+1
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEh0E3p4c3JKeBvsLGB1IKcBYmEmkFAmM19ZUACgkQB1IKcBYm
EmkEbBAAm5UCu4BTNWub0JzpHT+zh4G3HV6bTXxys44FjP8YWOp6s7CJU6XMiWMo
UMQDondudm8qiED+ubk1gihfQTfAtwSLO5rXf1mrxqFbJ2n9eazvitBYM4v7uxsh
M4BMCjPXCxSvbsfbzYCe6qodGc6nmT1/K+fXovJwl7I0WxCzOyELi3O4s5U/rsiU
osB2pNSN9X0nqywj7iaEsPYYswXVXN4QhXg2ogKEKsei41E7pZVWaix+JwPPYosa
81YK+18IyCCzVwXiQ8FsHBas6hxHVl2/l1XfhQoG/heQ7ZfbBSlDl7qSKceblDb4
Ue3cG365ejb2ghYtb3wBCH/WE3wDZ7H95OsCWbubJbr+TwyXLX5jlwV5cf9RoE2s
cw8jiX5nnmBTiIPt0ithvI0BfppjJAfjZkBVYzujpVVDgmKLV6HGfshg3xFDOmMJ
M9C1EIiapWWwnoISfgp/QL4YCFcP2lIE9Wgq88Dz9bd2dN43kStvxTu7uUkfgdr8
O0bYOv5etL8TrDAY63OEJ2d0RnttwFJnLLf8lrq3f0GT98Lb1OzS40rK8bE759VI
uZOyeRl3ntWl18HBIXnB7LVt6SDfMiwLrty2i+iFGFzDNxl9GYlZG4aqnLwt1EeG
gMuZeNVk5HzpdSqsxIs36jN4QeK/M7FiXlKPeeB2VB6q4EiifhU=
=23js
-----END PGP SIGNATURE-----

--Tq5f2PmMQquE+b+1--
