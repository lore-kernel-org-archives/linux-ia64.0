From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 10 May 2004 15:47:07 +0000
Subject: RE: [patch] 2.6.6 SN2 specific prom flag in mca.c
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F012F2E38@scsmsx401.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <11478.1084168536@kao2.melbourne.sgi.com>
In-Reply-To: <11478.1084168536@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>On Sunday 09 May 2004 11:55 pm, Keith Owens wrote:
>> SN2 prom needs an extra flag on the MCA setup call.
>
>If the flag is needed always and only on SN2, why doesn't the
>prom just set it implicitly?

The SAL spec is unhelpful about platform extensions here, it
defines bits 2-63 as "Reserved, must be zero".

-Tony
