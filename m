From: "Zhang, Yanmin" <yanmin.zhang@intel.com>
Date: Mon, 12 Dec 2005 07:06:50 +0000
Subject: RE: [BUG] Variable stopmachine_state should be volatile
Message-Id: <8126E4F969BA254AB43EA03C59F44E84042C56D5@pdsmsx404>
List-Id: <linux-ia64.vger.kernel.org>
References: <8126E4F969BA254AB43EA03C59F44E8404210E76@pdsmsx404>
In-Reply-To: <8126E4F969BA254AB43EA03C59F44E8404210E76@pdsmsx404>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: "Luck, Tony" <tony.luck@intel.com>, Arjan van de Ven <arjan@infradead.org>, Pavel Machek <pavel@ucw.cz>
Cc: linux-kernel@vger.kernel.org, "Pallipadi, Venkatesh" <venkatesh.pallipadi@intel.com>, "Shah, Rajesh" <rajesh.shah@intel.com>, linux-ia64@vger.kernel.org

>>-----Original Message-----
>>From: linux-ia64-owner@vger.kernel.org
>>[mailto:linux-ia64-owner@vger.kernel.org] On Behalf Of Luck, Tony
>>Sent: 2005=C4=EA12=D4=C29=C8=D5 2:53
>>To: Zhang, Yanmin; Arjan van de Ven; Pavel Machek
>>Cc: linux-kernel@vger.kernel.org; Pallipadi, Venkatesh; Shah, Rajesh;
>>linux-ia64@vger.kernel.org
>>Subject: RE: [BUG] Variable stopmachine_state should be volatile
>>
>>> The right approach is to define ia64_hint to ia64_barrier in file
>>> include/asm-ia64/intel_intrin.h. I tested the new approach and it
>>> does work.
>>
>>Does that get you a "hint@pause" instruction inside the loop?  If not, th=
en
>>it isn't all the way to the "right" approach.

Tony,

The approach just fixes compiler scheduling barrier problem of cpu_relax, a=
nd there is no hint@pause inside the loop.

Today I tried the latest icc, 9.0.027. It provides __hint, a new intrinsic,=
 to support hint@pause. __hint also has the meaning of compiler scheduling =
barrier. So the best solution is to use __hint(0). The disassembled result =
showed the new intrinsic did work.

