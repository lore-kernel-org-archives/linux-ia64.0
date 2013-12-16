From: David Miller <davem@davemloft.net>
Date: Mon, 16 Dec 2013 01:27:25 +0000
Subject: Re: [PATCH 10/10] Kconfig: cleanup SERIO_I8042 dependencies
Message-Id: <20131215.202725.1549146673897801643.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <52ACA43F.2040402@zytor.com>
 <20131215103657.GB20197@core.coreip.homeip.net>
 <1387122626.1979.136.camel@deneb.redhat.com>
In-Reply-To: <1387122626.1979.136.camel@deneb.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

From: Mark Salter <msalter@redhat.com>
Date: Sun, 15 Dec 2013 10:50:26 -0500

> On Sun, 2013-12-15 at 02:36 -0800, Dmitry Torokhov wrote:
>> How are we going to merge this? In bulk through input tree or peacemeal
>> through all arches first?
>
> They should all go together to eliminate the chance of bisect breakage.
> Either the input tree or maybe akpm tree.

This sounds good to me.
