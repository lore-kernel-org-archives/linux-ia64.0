From: Sebastian Reichel <sebastian.reichel@collabora.com>
Date: Thu, 26 Jan 2023 17:07:39 +0000
Subject: Re: [PATCH v2 3/6] mm: replace vma->vm_flags direct modifications with modifier calls
Message-Id: <20230126170739.mlka2jivn3mfstyf@mercury.elektranox.org>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="qcyccrleajamxo75"
List-Id: <linux-ia64.vger.kernel.org>
References: <20230125083851.27759-1-surenb@google.com>
 <20230125083851.27759-4-surenb@google.com>
In-Reply-To: <20230125083851.27759-4-surenb@google.com>
To: Suren Baghdasaryan <surenb@google.com>
Cc: akpm@linux-foundation.org, michel@lespinasse.org, jglisse@google.com, mhocko@suse.com, vbabka@suse.cz, hannes@cmpxchg.org, mgorman@techsingularity.net, dave@stgolabs.net, willy@infradead.org, liam.howlett@oracle.com, peterz@infradead.org, ldufour@linux.ibm.com, paulmck@kernel.org, luto@kernel.org, songliubraving@fb.com, peterx@redhat.com, david@redhat.com, dhowells@redhat.com, hughd@google.com, bigeasy@linutronix.de, kent.overstreet@linux.dev, punit.agrawal@bytedance.com, lstoakes@gmail.com, peterjung1337@gmail.com, rientjes@google.com, axelrasmussen@google.com, joelaf@google.com, minchan@google.com, jannh@google.com, shakeelb@google.com, tatashin@google.com, edumazet@google.com, gthelen@google.com, gurua@google.com, arjunroy@google.com, soheil@google.com, hughlynch@google.com, leewalsh@google.com, posk@google.com, will@kernel.org, aneesh.kumar@linux.ibm.com, npiggin@gmail.com, chenhuacai@kernel.org, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, richard@nod.at, anton.ivanov@cambridgegreys.com, johannes@sipsolutions.net, qianweili@huawei.com, wangzhou1@hisilicon.com, herbert@gondor.apana.org.au, davem@davemloft.net, vkoul@kernel.org, airlied@gmail.com, daniel@ffwll.ch, maarten.lankhorst@linux.intel.com, mripard@kernel.org, tzimmermann@suse.de, l.stach@pengutronix.de, krzysztof.kozlowski@linaro.org, patrik.r.jakobsson@gmail.com, matthias.bgg@gmail.com, robdclark@gmail.com, quic_abhinavk@quicinc.com, dmitry.baryshkov@linaro.org, tomba@kernel.org, hjc@rock-chips.com, heiko@sntech.de, ray.huang@amd.com, kraxel@redhat.com, mcoquelin.stm32@gmail.com, alexandre.torgue@foss.st.com, tfiga@chromium.org, m.szyprowski@samsung.com, mchehab@kernel.org, dimitri.sivanich@hpe.com, zhangfei.gao@linaro.org, jejb@linux.ibm.com, martin.petersen@oracle.com, dgilbert@interlog.com, hdegoede@redhat.com, mst@redhat.com, jasowang@redhat.com, alex.williamson@redhat.com, deller@gmx.de, jayalk@intworks.biz, viro@zeniv.linux.org.uk, nico@fluxnic.net, xiang@kernel.org, chao@kernel.org, tytso@mit.edu, adilger.kernel@dilger.ca, miklos@szeredi.hu, mike.kravetz@oracle.com, muchun.song@linux.dev, bhe@redhat.com, andrii@kernel.org, yoshfuji@linux-ipv6.org, dsahern@kernel.org, kuba@kernel.org, pabeni@redhat.com, perex@perex.cz, tiwai@suse.com, haojian.zhuang@gmail.com, robert.jarzmik@free.fr, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, linux-kernel@vger.kernel.org, linux-graphics-maintainer@vmware.com, linux-ia64@vger.kernel.org, linux-arch@vger.kernel.org, loongarch@lists.linux.dev, kvm@vger.kernel.org, linux-s390@vger.kernel.org, linux-sgx@vger.kernel.org, linux-um@lists.infradead.org, linux-acpi@vger.kernel.org, linux-crypto@vger.kernel.org, nvdimm@lists.linux.dev, dmaengine@vger.kernel.org, amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, etnaviv@lists.freedesktop.org, linux-samsung-soc@vger.kernel.org, intel-gfx@lists.freedesktop.org, linux-mediatek@lists.infradead.org, linux-arm-msm@vger.kernel.org, freedreno@lists.freedesktop.org, linux-rockchip@lists.infradead.org, linux-tegra@vger.kernel.org, virtualization@lists.linux-foundation.org, xen-devel@lists.xenproject.org, linux-stm32@st-md-mailman.stormreply.com, linux-rdma@vger.kernel.org, linux-media@vger.kernel.org, linux-accelerators@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-scsi@vger.kernel.org, linux-staging@lists.linux.dev, target-devel@vger.kernel.org, linux-usb@vger.kernel.org, netdev@vger.kernel.org, linux-fbdev@vger.kernel.org, linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-erofs@lists.ozlabs.org, linux-ext4@vger.kernel.org, devel@lists.orangefs.org, kexec@lists.infradead.org, linux-xfs@vger.kernel.org, bpf@vger.kernel.org, linux-perf-users@vger.kernel.org, kasan-dev@googlegroups.com, selinux@vger.kernel.org, alsa-devel@alsa-project.org, kernel-team@android.com


--qcyccrleajamxo75
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Wed, Jan 25, 2023 at 12:38:48AM -0800, Suren Baghdasaryan wrote:
> Replace direct modifications to vma->vm_flags with calls to modifier
> functions to be able to track flag changes and to keep vma locking
> correctness.
>=20
> Signed-off-by: Suren Baghdasaryan <surenb@google.com>
> ---
> [...]
>  drivers/hsi/clients/cmt_speech.c                   |  2 +-
>  120 files changed, 188 insertions(+), 199 deletions(-)
> [...]
> diff --git a/drivers/hsi/clients/cmt_speech.c b/drivers/hsi/clients/cmt_s=
peech.c
> index 8069f795c864..952a31e742a1 100644
> --- a/drivers/hsi/clients/cmt_speech.c
> +++ b/drivers/hsi/clients/cmt_speech.c
> @@ -1264,7 +1264,7 @@ static int cs_char_mmap(struct file *file, struct v=
m_area_struct *vma)
>  	if (vma_pages(vma) !=3D 1)
>  		return -EINVAL;
> =20
> -	vma->vm_flags |=3D VM_IO | VM_DONTDUMP | VM_DONTEXPAND;
> +	set_vm_flags(vma, VM_IO | VM_DONTDUMP | VM_DONTEXPAND);
>  	vma->vm_ops =3D &cs_char_vm_ops;
>  	vma->vm_private_data =3D file->private_data;
> =20

Acked-by: Sebastian Reichel <sebastian.reichel@collabora.com>

-- Sebastian

--qcyccrleajamxo75
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEE72YNB0Y/i3JqeVQT2O7X88g7+poFAmPSs1EACgkQ2O7X88g7
+pquLBAAkw9lw9lxNRCI6jvqLy98JsUBgSQigNB6Eh8JVWsySHMm1OszFCcvTpoc
vinC/VPMOa6JwEw5e9naXRF2UJahO+Cx+e5MYIKos3QyIUPfi0YM7Cv96h6+c4l/
NdcxLS8+9ElitTuA47UVgPSeZwzdZ1kU5VUV1X2fx+6aGA+dBfWVBgWDqU6AB0Sa
ehU4betso5Ypl26YEmLPHmY+8Xx2jXNwwBEgsHgO2/YjRn9YPDeMAqb4lWs99h0d
nUV1VqwTClRrExtNDvidHryknmyCIBpYt38gn0i9+uIf9mFoBmUDN+/zAdRguGBT
r1CQAwvRvHmEyGJ4dp1nijyt/PWxDBlCWytlmzXrK/rkeH8sQCRdCr9L83/d5DM0
iU98ehmbH9kx8rD4y0L91xmsnegNYNKSfAvz3EP4KYFOHjTw2SOCYoazPu3z62bN
d3HL+08LeZpm1XwVPydZqBd5UpBK8NaQYCJ3BjsLUefsSJE+SWzsnoYFnbUrL1X9
1XfU6LGtVvjCPUsjk7oqh5PjtRGQsdtUhSZJLwNzTeh4I0nSzL1pj8vRFZ7UTcV4
RmFYsjBbKhja2fC13eM4tKzfx53harnHVNuUPw2aoLKshpkQaOTUqWBnRXtbJZkb
dSRKObxfPlHVI+awnfN6owpXF86Owew2+XJcXILOPxaBk8PI/Ns=
=/0TB
-----END PGP SIGNATURE-----

--qcyccrleajamxo75--
