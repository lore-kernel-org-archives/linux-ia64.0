From: "Liu, Benjamin" <benjamin.liu@intel.com>
Date: Fri, 27 Feb 2004 09:18:41 +0000
Subject: RE: General question about building kernel.org distros
Message-Id: <3ACA40606221794F80A5670F0AF15F8401B19FBC@PDSMSX403.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <403D151C.1F7A96D1@email.mot.com>
In-Reply-To: <403D151C.1F7A96D1@email.mot.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

It seems that you missed the ia64 patch, check here <http://www.kernel.org/=
pub/linux/kernel/ports/ia64/v2.4/>.

Mainline kernel is mainly for i386. Things are becoming better in 2.6(witho=
ut ia64 patch you can still build the image some time). But for 2.4, you ar=
e not that lucky most of the time.

Thanks,
Pingping (Benjamin) Liu
Intel China Software Center


>-----Original Message-----
>From: linux-ia64-owner@vger.kernel.org=20
>[mailto:linux-ia64-owner@vger.kernel.org] On Behalf Of Mario Smarduch
>Sent: 2004=C4=EA2=D4=C226=C8=D5 5:35
>To: IA-64 Mailing List (New)
>Subject: General question about building kernel.org distros
>
>
>Hi,
>
>I just have a general question regarding building IA64 2.4.25
>stock kernel from kernel.org. After downloading, and building
>with the default  config there were tons of compile errors. These were
>some obvious errors like functions accepting more or less
>parameters then call sites were providing and tons of other
>obvious errors independent of the configuration. Eventually
>I plugged up all the errors and the thing comes up and seems
>to stay up.
>
>Is this sort of normal when building a source tree from kernel.org
>for IA64 or am I missing something?
>
>For i386 I have no problems like that. I'm a bit concerned
>if a vendor uses this as base for a distribution and has
>to plug up all these holes, you kind of wonder if there are
>any bugs  left behind.
>
>- Mario.
>
>-
>To unsubscribe from this list: send the line "unsubscribe=20
>linux-ia64" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
