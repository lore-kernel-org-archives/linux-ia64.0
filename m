From: Grant Grundler <iod00d@hp.com>
Date: Mon, 08 Mar 2004 06:30:44 +0000
Subject: Re: [PATCH] fix PCI interrupt setting for ia64
Message-Id: <20040308063044.GB25960@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <MDEEKOKJPMPMKGHIFAMAKECGDGAA.kaneshige.kenji@jp.fujitsu.com>
In-Reply-To: <MDEEKOKJPMPMKGHIFAMAKECGDGAA.kaneshige.kenji@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Mar 08, 2004 at 11:49:10AM +0900, Kenji Kaneshige wrote:
> In ia64 kernel, IOSAPIC's RTEs for PCI interrupts are unmasked at the
> boot time before installing device drivers. I think it is very dangerous.

Hi Kenji,
I think this behavior exists to support "legacy" IRQ probing.
I'm wondering if it would be sufficient to wrap the patch in
"#ifndef CONFIG_ISA" or something like that.

grant
