From: "Liu, Benjamin" <benjamin.liu@intel.com>
Date: Fri, 12 Mar 2004 09:15:09 +0000
Subject: RE: 2.6.3 compilation problem
Message-Id: <3ACA40606221794F80A5670F0AF15F8401B1A07C@PDSMSX403.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <002f01c40735$8d2cc880$39624c0f@india.hp.com>
In-Reply-To: <002f01c40735$8d2cc880$39624c0f@india.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Yes, I agree.

Thanks,
Pingping (Benjamin) Liu
Intel China Software Center


>-----Original Message-----
>From: Keith Owens [mailto:kaos@ocs.com.au]=20
>Sent: 2004=C4=EA3=D4=C212=C8=D5 14:01
>To: H. J. Lu
>Cc: Liu, Benjamin; Chen, Kenneth W; Sourav Sen;=20
>linux-ia64@vger.kernel.org
>Subject: Re: 2.6.3 compilation problem=20
>
>
>On Thu, 11 Mar 2004 21:42:04 -0800,=20
>"H. J. Lu" <hjl@lucon.org> wrote:
>>which means it will be discarded if the driver is builtin. If
>>xxx_remove may be discarded, please make sure there is
>>
>>#ifdef MODULE
>>	remove:	       xxx_remove,
>>#endif
>>
>>so that xxx_remove won't be included when the driver is builtin.
>
>	remove:		__devexit_p(xxx_remove),
>
>is the correct method.  The pointer is required for CONFIG_MODULE
>_or_ CONFIG_HOTPLUG, otherwise it must be set to NULL.  __devexit_p()
>does all that.
>
>
