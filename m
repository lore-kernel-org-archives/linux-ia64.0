From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Sun, 18 Jul 2004 19:57:40 +0000
Subject: Re: [PATCH] update sn2_defconfig to include new console
Message-Id: <200407181557.40248.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_0Yt+AAVNIZDe3/j"
List-Id: <linux-ia64.vger.kernel.org>
References: <200407171704.08219.jbarnes@engr.sgi.com>
In-Reply-To: <200407171704.08219.jbarnes@engr.sgi.com>
To: linux-ia64@vger.kernel.org


--Boundary-00=_0Yt+AAVNIZDe3/j
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Sunday, July 18, 2004 3:34 pm, Jesse Barnes wrote:
> On Saturday, July 17, 2004 7:24 pm, Keith Owens wrote:
> > On Sat, 17 Jul 2004 17:04:08 -0400,
> >
> > Jesse Barnes <jbarnes@engr.sgi.com> wrote:
> > >===== arch/ia64/configs/sn2_defconfig 1.8 vs edited =====
> > >--- 1.8/arch/ia64/configs/sn2_defconfig	2004-06-24 06:42:21 -07:00
> > >+++ edited/arch/ia64/configs/sn2_defconfig	2004-07-17 09:24:59 -07:00
> > >@@ -24,6 +24,7 @@
> > > # CONFIG_EMBEDDED is not set
> > > CONFIG_KALLSYMS=y
> > > CONFIG_KALLSYMS_ALL=y
> > >+CONFIG_KALLSYMS_EXTRA_PASS=y
> >
> > CONFIG_KALLSYMS_EXTRA_PASS should not be turned on by default.  It is
> > only to be used when there is a bug in the kallsyms code, the extra
> > pass provides debugging data and lets the users continue to build while
> > we work out what is wrong with kallsyms.
>
> Oh, I see.  I thought it was a 'double check' against bad values.  I'll
> send out another update shortly that turns it off.

Here it is, live from Ottawa.

Jesse

--Boundary-00=_0Yt+AAVNIZDe3/j
Content-Type: text/x-diff;
  charset="iso-8859-1";
  name="sn2-defconfig-console-2.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="sn2-defconfig-console-2.patch"


--Boundary-00=_0Yt+AAVNIZDe3/j--
