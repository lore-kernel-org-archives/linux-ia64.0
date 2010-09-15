From: Tony Luck <tony.luck@intel.com>
Date: Wed, 15 Sep 2010 17:28:59 +0000
Subject: Re: [PATCH 0/2] ia64: possible module unwind table optimisation
Message-Id: <AANLkTi=hPcXC1=Lrey1H_UHRJRJ-NdTsvmyxgP_n+dM8@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1284115245-23876-1-git-send-email-ext-phil.2.carmody@nokia.com>
	<AANLkTi=RsA0tACWOg+8RTSuDHwa4LGOiyO-4TxpJ_rb5@mail.gmail.com>
	<20100915124831.GB27658@esdhcp04044.research.nokia.com>
In-Reply-To: <20100915124831.GB27658@esdhcp04044.research.nokia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Phil Carmody <ext-phil.2.carmody@nokia.com>
Cc: "fenghua.yu@intel.com" <fenghua.yu@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, Sep 15, 2010 at 5:48 AM, Phil Carmody
<ext-phil.2.carmody@nokia.com> wrote:
>> =A0 for (table =3D unw.tables; table; table =3D table->next)
>>
>> before we find the right table to look?
>
> Yes, that's the one. Sorry I wasn't more explicit.

My usual workload (building new Linux kernels - what else :-) doesn't
seem to generate
any unwind requests.  I reached the loop just 58 times while booting,
and only did 23
steps past the first item [didn't track a histogram, so I don't know
whether that was a
single 23 step lookup, or 23 one-step ones].  Building the kernel
(make -j32) didn't add
to either count.

Workload ideas?

-Tony
