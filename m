From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Wed, 16 Feb 2022 19:05:47 +0000
Subject: Re: [PATCH][next] treewide: Replace zero-length arrays with flexible-array members
Message-Id: <CAJZ5v0jpAnQk+Hub6ue6t712RW+W0YBjb_gAcZZbUeuYMGv7mg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220215174743.GA878920@embeddedor> <202202151016.C0471D6E@keescook>
 <20220215192110.GA883653@embeddedor> <Ygv8wY75hNqS7zO6@unreal> <20220215193221.GA884407@embeddedor>
In-Reply-To: <20220215193221.GA884407@embeddedor>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Gustavo A. R. Silva" <gustavoars@kernel.org>
Cc: Leon Romanovsky <leon@kernel.org>, Kees Cook <keescook@chromium.org>, GR-QLogic-Storage-Upstream@marvell.com, linux-alpha@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, Linux-sh list <linux-sh@vger.kernel.org>, sparclinux@vger.kernel.org, linux-um@lists.infradead.org, linux-xtensa@linux-xtensa.org, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, intel-gfx <intel-gfx@lists.freedesktop.org>, dri-devel <dri-devel@lists.freedesktop.org>, nouveau <nouveau@lists.freedesktop.org>, coresight@lists.linaro.org, Linux ARM <linux-arm-kernel@lists.infradead.org>, bcm-kernel-feedback-list <bcm-kernel-feedback-list@broadcom.com>, netdev <netdev@vger.kernel.org>, Linux OMAP Mailing List <linux-omap@vger.kernel.org>, "open list:TARGET SUBSYSTEM" <linux-scsi@vger.kernel.org>, target-devel@vger.kernel.org, mpi3mr-linuxdrv.pdl@broadcom.com, linux-staging@lists.linux.dev, linux-rpi-kernel@lists.infradead.org, sparmaintainer@unisys.com, linux-cifs@vger.kernel.org, samba-technical@lists.samba.org, Ext4 Developers List <linux-ext4@vger.kernel.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, "open list:ACPI COMPONENT ARCHITECTURE (ACPICA)" <devel@acpica.org>, linux-arch <linux-arch@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, greybus-dev@lists.linaro.org, linux-i3c@lists.infradead.org, linux-rdma@vger.kernel.org, "open list:BLUETOOTH DRIVERS" <linux-bluetooth@vger.kernel.org>, "moderated list:SOUND - SOC LAYER / DYNAMIC AUDIO POWER MANAGEM..." <alsa-devel@alsa-project.org>, "open list:OPEN FIRMWARE AND FLATTENED DEVICE TREE BINDINGS" <devicetree@vger.kernel.org>, linux-perf-users@vger.kernel.org, linux-hardening@vger.kernel.org

On Tue, Feb 15, 2022 at 8:24 PM Gustavo A. R. Silva
<gustavoars@kernel.org> wrote:
>
> On Tue, Feb 15, 2022 at 09:19:29PM +0200, Leon Romanovsky wrote:
> > On Tue, Feb 15, 2022 at 01:21:10PM -0600, Gustavo A. R. Silva wrote:
> > > On Tue, Feb 15, 2022 at 10:17:40AM -0800, Kees Cook wrote:
> > > > On Tue, Feb 15, 2022 at 11:47:43AM -0600, Gustavo A. R. Silva wrote:
> > > >
> > > > These all look trivially correct to me. Only two didn't have the end of
> > > > the struct visible in the patch, and checking those showed them to be
> > > > trailing members as well, so:
> > > >
> > > > Reviewed-by: Kees Cook <keescook@chromium.org>
> > >
> > > I'll add this to my -next tree.
> >
> > I would like to ask you to send mlx5 patch separately to netdev. We are working
> > to delete that file completely and prefer to avoid from unnecessary merge conflicts.
>
> Oh OK. Sure thing; I will do so.

Can you also send the ACPI patch separately, please?

We would like to route it through the upstream ACPICA code base.
