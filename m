From: "Liu, Benjamin" <benjamin.liu@intel.com>
Date: Fri, 12 Mar 2004 03:52:59 +0000
Subject: RE: 2.6.3 compilation problem
Message-Id: <3ACA40606221794F80A5670F0AF15F8401B1A06E@PDSMSX403.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <002f01c40735$8d2cc880$39624c0f@india.hp.com>
In-Reply-To: <002f01c40735$8d2cc880$39624c0f@india.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Sourav,

Could you please send out your configure file in attachment? I can not repr=
oduce your issue even when I configured CONFIG_SERIO.

Ken, it's too early to make any judgement.

Thanks,
Pingping (Benjamin) Liu
Intel China Software Center


>-----Original Message-----
>From: Chen, Kenneth W=20
>Sent: 2004=C4=EA3=D4=C212=C8=D5 2:38
>To: Liu, Benjamin; Sourav Sen; linux-ia64@vger.kernel.org
>Subject: RE: 2.6.3 compilation problem
>
>
>>>>>> Liu, Benjamin wrote on Thu, March 11, 2004 12:33 AM
>> To workaround the problem, you can append=20
>__attribute__((weak)) to the
>> declaration of those discarded symbols defined in section=20
>".exit.text".
>>
>> The device driver author might be able to answer why it is=20
>written that
>> way.
>
>The linker gets the award for least informative in this case,=20
>and it just
>plain misleading.  The culprit isn't the one printed.  It lies=20
>somewhere
>else.
>
>- Ken
>
>
>
