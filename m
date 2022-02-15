From: Leon Romanovsky <leon@kernel.org>
Date: Tue, 15 Feb 2022 19:19:29 +0000
Subject: Re: [PATCH][next] treewide: Replace zero-length arrays with flexible-array members
Message-Id: <Ygv8wY75hNqS7zO6@unreal>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220215174743.GA878920@embeddedor>
 <202202151016.C0471D6E@keescook>
 <20220215192110.GA883653@embeddedor>
In-Reply-To: <20220215192110.GA883653@embeddedor>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: "Gustavo A. R. Silva" <gustavoars@kernel.org>
Cc: Kees Cook <keescook@chromium.org>, GR-QLogic-Storage-Upstream@marvell.com, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-um@lists.infradead.org, linux-xtensa@linux-xtensa.org, linux-crypto@vger.kernel.org, intel-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, nouveau@lists.freedesktop.org, coresight@lists.linaro.org, linux-arm-kernel@lists.infradead.org, bcm-kernel-feedback-list@broadcom.com, netdev@vger.kernel.org, linux-omap@vger.kernel.org, linux-scsi@vger.kernel.org, target-devel@vger.kernel.org, mpi3mr-linuxdrv.pdl@broadcom.com, linux-staging@lists.linux.dev, linux-rpi-kernel@lists.infradead.org, sparmaintainer@unisys.com, linux-cifs@vger.kernel.org, samba-technical@lists.samba.org, linux-ext4@vger.kernel.org, linux-acpi@vger.kernel.org, devel@acpica.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, greybus-dev@lists.linaro.org, linux-i3c@lists.infradead.org, linux-rdma@vger.kernel.org, linux-bluetooth@vger.kernel.org, alsa-devel@alsa-project.org, devicetree@vger.kernel.org, linux-perf-users@vger.kernel.org, linux-hardening@vger.kernel.org

On Tue, Feb 15, 2022 at 01:21:10PM -0600, Gustavo A. R. Silva wrote:
> On Tue, Feb 15, 2022 at 10:17:40AM -0800, Kees Cook wrote:
> > On Tue, Feb 15, 2022 at 11:47:43AM -0600, Gustavo A. R. Silva wrote:
> > > There is a regular need in the kernel to provide a way to declare
> > > having a dynamically sized set of trailing elements in a structure.
> > > Kernel code should always use “flexible array members”[1] for these
> > > cases. The older style of one-element or zero-length arrays should
> > > no longer be used[2].
> > > 
> > > This code was transformed with the help of Coccinelle:
> > > (next-20220214$ spatch --jobs $(getconf _NPROCESSORS_ONLN) --sp-file script.cocci --include-headers --dir . > output.patch)
> > > 
> > > @@
> > > identifier S, member, array;
> > > type T1, T2;
> > > @@
> > > 
> > > struct S {
> > >   ...
> > >   T1 member;
> > >   T2 array[
> > > - 0
> > >   ];
> > > };
> > 
> > These all look trivially correct to me. Only two didn't have the end of
> > the struct visible in the patch, and checking those showed them to be
> > trailing members as well, so:
> > 
> > Reviewed-by: Kees Cook <keescook@chromium.org>
> 
> I'll add this to my -next tree.

I would like to ask you to send mlx5 patch separately to netdev. We are working
to delete that file completely and prefer to avoid from unnecessary merge conflicts.

Thanks

> 
> Thanks!
> --
> Gustavo
