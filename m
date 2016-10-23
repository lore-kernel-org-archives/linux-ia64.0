From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 23 Oct 2016 06:33:09 +0000
Subject: Re: IA64-sn2_smp: Combine two seq_printf() calls into one call in sn2_ptc_seq_show()
Message-Id: <f81a64c4-a531-02e4-6d89-561589722028@users.sourceforge.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <8daf03e1-5f6d-fc3b-c2db-397e6d4a9a1c@users.sourceforge.net>
 <c3e12189-6122-e806-6cb2-b2518e64e983@users.sourceforge.net>
 <1477166856.3817.4.camel@perches.com>
 <72f6fc41-9bf8-2eef-848f-8eefba7dade6@users.sourceforge.net>
 <alpine.DEB.2.20.1610230741400.1972@hadrien>
In-Reply-To: <alpine.DEB.2.20.1610230741400.1972@hadrien>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julia Lawall <julia.lawall@lip6.fr>, linux-ia64@vger.kernel.org
Cc: Joe Perches <joe@perches.com>, Al Viro <viro@zeniv.linux.org.uk>, Borislav Petkov <bp@suse.de>, Fenghua Yu <fenghua.yu@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Hans-Christian Noren Egtvedt <egtvedt@samfundet.no>, Ingo Molnar <mingo@kernel.org>, =?UTF-8?B?SsO2cmcgUsO2ZGVs?= <jroedel@suse.de>, Krzysztof Kozlowski <krzk@kernel.org>, Robert Richter <rrichter@cavium.com>, Robin Murphy <robin.murphy@arm.com>, Tony Luck <tony.luck@intel.com>, Toshi Kani <toshi.kani@hpe.com>, Vineet Gupta <vgupta@synopsys.com>, LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org

>> Would you prefer to use this function also at this source code place?
> 
> I think that he is expecting that you will figure out the answer by yourself.

I know some answer possibilities for the potential usage of the
function "seq_puts" also within the implementation of the function "sn2_ptc_seq_show".
I am unsure about the consensus of the involved developers for this
software module as usual.

Regards,
Markus
