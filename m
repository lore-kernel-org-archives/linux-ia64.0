From: Ingo Molnar <mingo@elte.hu>
Date: Mon, 20 Jun 2011 07:41:24 +0000
Subject: Re: [PATCH 00/10] Enhance /dev/mem to allow read/write of arbitrary
Message-Id: <20110620074124.GB24716@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <201106171038.25988.ptesarik@suse.cz>
	<20110617093032.GA19235@elte.hu> <4DFE7FF9.9070406@gmail.com>
	<4DFE89E0.5020509@zytor.com>
In-Reply-To: <4DFE89E0.5020509@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org


* H. Peter Anvin <hpa@zytor.com> wrote:

> There are some test drivers which really want /dev/mem to work.

Test drivers and test hardware with zero enumeration can use below 4G 
addresses just fine.

Also, debugging is not an issue and some non-default kernel or boot 
option can enable any sort of device i guess, so my main worry isnt 
really security but that we should stand in the way of the apparent 
practice of *shipping* user-space drivers that use /dev/mem ...

Thanks,

	Ingo
