From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 01 Sep 2009 23:20:34 +0000
Subject: RE: [RFC][PATCH] ia64: fix csum_ipv6_magic()
Message-Id: <57C9024A16AD2D4C97DC78E552063EA3E038D4AE@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090827211113.GA22793@midget.suse.cz>
 <A6AD88C3F2289247BE726C37303E1EB8B954B4A6@orsmsx505.amr.corp.intel.com>
In-Reply-To: <A6AD88C3F2289247BE726C37303E1EB8B954B4A6@orsmsx505.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Yu, Fenghua" <fenghua.yu@intel.com>, 'Jiri Bohac' <jbohac@suse.cz>
Cc: "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-ia64@vger.kernel.org'" <linux-ia64@vger.kernel.org>

>--- a/arch/ia64/lib/ip_fast_csum.S
>+++ b/arch/ia64/lib/ip_fast_csum.S
>@@ -96,20 +96,22 @@ END(ip_fast_csum)
> GLOBAL_ENTRY(csum_ipv6_magic)
> 	ld4	r20=[in0],4
> 	ld4	r21=[in1],4
>-	dep	r15=in3,in2,32,16
>+	zxt4	in3=in3

I think this zxt4 instruction have a typo.  You really want to zap the
high part on "in2" here (the "len") parameter.  "in3" contains the "proto"
argument, which is only 16-bits.  But any garbage in the high part on in3
will be dropped by the "dep" instruction later which only pulls out the low
16 bits from it.

So I think you meant to type:

	zxt4	in2=in2

Does this make sense?

-Tony
