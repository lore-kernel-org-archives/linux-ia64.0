From: "Miller, Mike (OS Dev)" <Mike.Miller@COMPAQ.com>
Date: Wed, 27 Jun 2001 15:50:07 +0000
Subject: RE: [Linux-ia64] Interrupt redirection problem
Message-Id: <marc-linux-ia64-105590693005782@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005755@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005755@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I think it's actually the BSP that processes most of the interrupts. It
could be cpu0 on one boot, and another cpu on a subsequent boot.

mikem

-----Original Message-----
From: Martin Wilck [mailto:Martin.Wilck@fujitsu-siemens.com]
Sent: Wednesday, June 27, 2001 3:22 AM
To: Linux-IA64 Mailing list
Subject: Re: [Linux-ia64] Interrupt redirection problem



Andreas Schwab wrote:
>
> As you can see, cpu0 is processing the majority of interrupts (91%,
> ignoring the SAPIC interrupts).  Why?

This is not the case on my system. On the contrary, CPU3 seems to receive
the vast majority of interrupts. (I have "Force IRQ redirection" enabled).

 52:        139          1        671     167542  IO-SAPIC-level  e100
 54:          0          0          0          0  IO-SAPIC-level  usb-uhci
 57:          0          0          5       8072  IO-SAPIC-level  Mylex
eXtremeRAID 2000
 61:         21          1       1856      66170  IO-SAPIC-level  qla1280
 63:          0          0        178       3896  IO-SAPIC-level  aic7xxx

Martin

-- 
Martin Wilck     <Martin.Wilck@fujitsu-siemens.com>
FSC EP PS DS1, Paderborn      Tel. +49 5251 8 15113




_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64

