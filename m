From: Christian Hildner <christian.hildner@hob.de>
Date: Fri, 04 Mar 2005 13:22:36 +0000
Subject: Re: Using ski to debug linux kernel ?
Message-Id: <4228611C.6090305@hob.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050304122112.19543.qmail@web51104.mail.yahoo.com>
In-Reply-To: <20050304122112.19543.qmail@web51104.mail.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

baswaraj kasture schrieb:

>I want to debug linux kernel (IA-64)  with SKI. I have
>created   simulated disk image. Where do i put my
>kernel image ? on the simulated disk or some where
>else ?
>
The command line is:

(x)ski bootloader your_kernel simscsi=your_diskimage

bootloader is created from the kernel sources

your_kernel must be configured with CONFIG_IA64_HP_SIM active
your_kernel does not need to be in the disk image

You'll find more information in the ski howto files.

>I tried putting kernel image on simulated disk (in
>boot directory ), but didn't suceed ? could someone
>help me in this regard ? 
>
If you have further questions there is a wonderful mailing list special 
for the simulator at lia64-sim@napali.hpl.hp.com . There are some really 
experienced experts listening.

Christian

>Thanks,
>-Baswaraj
>
>  
>


