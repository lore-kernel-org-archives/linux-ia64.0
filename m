From: Christian Hildner <christian.hildner@hob.de>
Date: Tue, 08 Feb 2005 07:59:14 +0000
Subject: Re: How to use ski to debug linux kernel ?
Message-Id: <42087152.8030802@hob.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050208051807.92001.qmail@web51109.mail.yahoo.com>
In-Reply-To: <20050208051807.92001.qmail@web51109.mail.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

baswaraj kasture schrieb:

>Does anybody knows how to use sky to debug  linux
>kernel ?
>
You have to configure the kernel to be used in ski. It is not possible 
to run a generic kernel under ski since ski only emulates the raw 
processor and lacks firmware and peripherals. The kernel itself has 
emulation for these missing things but you have to use CONFIG_IA64_HP_SIM.

Also there is a separate mailing list at 
http://www.hpl.hp.com/research/linux/ski/mail.php

On the HP site you'll find also howto docs regarding ski.

Christian

>I used follwing command to debug kernel with ski,
>
>#ski iccvmlinux
>
>but it stops the simulation displaying the message
>"Halting Simulation" .
>Any ideas regarding this ?
>
>Thanx,
>-Baswaraj
>

