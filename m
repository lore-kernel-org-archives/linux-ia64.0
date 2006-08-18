From: "Zou, Nanhai" <nanhai.zou@intel.com>
Date: Fri, 18 Aug 2006 00:48:48 +0000
Subject: RE: [patch 3/5] git-ia64 versus genirq
Message-Id: <08B1877B2880CE42811294894F33AD5C053BBF@pdsmsx411.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060817071455.164893000@tabatha.lab.ultramonkey.org>
In-Reply-To: <20060817071455.164893000@tabatha.lab.ultramonkey.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

> -----Original Message-----
> From: Horms [mailto:horms@verge.net.au]
> Sent: 2006=C4=EA8=D4=C218=C8=D5 8:39
> To: Eric W. Biederman
> Cc: Andrew Morton; fastboot@osdl.org; Zou, Nanhai; Luck, Tony;
> linux-ia64@vger.kernel.org
> Subject: Re: [patch 3/5] git-ia64 versus genirq
>=20
> On Thu, 17 Aug 2006 07:58:45 -0600, Eric W. Biederman wrote:
> > Horms <horms@verge.net.au> writes:
> >
> >> On Thu, 17 Aug 2006 00:28:53 -0700, Andrew Morton wrote:
> >>> On Thu, 17 Aug 2006 16:07:22 +0900
> >>> horms@tabatha.lab.ultramonkey.org wrote:
> >>>
> >>>> > commit 1f4c5c1fe2a6a74271989ec079af11e2bb8e2826
> >>>> > tree a0da63a3dcc3ffd71653ecc039db416dbcaa86d4
> >>>> > parent beada884dd437b509c26b39f1a0b0c6b31e6f340
> >>>> > author Andrew Morton <akpm@osdl.org> 1151573360 -0700
> >>>> > committer Tony Luck <tony.luck@intel.com> 1151607053 -0700
> >>>> >
> >>>> > [IA64] git-ia64 versus genirq
> >>>> >
> >>>> > Fix the git-ia64 tree after genirq merge.
> >>>> >
> >>>> > Signed-off-by: Andrew Morton <akpm@osdl.org>
> >>>> > Signed-off-by: Tony Luck <tony.luck@intel.com>
> >>>>
> >>>> Patch from test branch of Tony Luck's ia64 tree.
> >>>> This is needed for ia64 kexec in Linus's tree.
> >>>>
> >>>
> >>> I think you're telling us that Tony needs to get this into mainline, =
yes?
> >>
> >> This would be ia64 kexec.
> problem.
> >>
> >> At OLS Tony spoke about what state he would like to see kexec in before
> >> it is merged into Linus' tree. Basically reports that it works on
> >> at least a cople of different vendor's gear. That is proving harder
> >> than one might have hoped. But the code is marked as experimental,
> >> and if pushing it into Linus's tree both makes patch management a bit
> >> easier, and potentially gives the code better testing, then it seems
> Hi Eric,
>=20
> Clearly you are right that it would be a lot nicer to resolve the
> problem in the init path. Perhaps an interim solution would be to wrap
> these bits of code in #ifdef CONFIG_IA64_HP_ZX1 (Nan hai, would that
> cover the hardware that you are seeing the problem on?) and/or break it
> out into a separate add-on, very-wip patch.


Hi Horms,
	I have little knowledge of the code inside CONFIG_IA64_HP_ZX1....
I think it stop's IOMMU controller on some HP boxes.

Aziz told me it is necessary to have this code to start up the second kerne=
l.
Thanks
Zou Nan hai

> Horms
>   H: http://www.vergenet.net/~horms/
>   W: http://www.valinux.co.jp/en/
