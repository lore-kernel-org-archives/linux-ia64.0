From: "White, Charles" <Charles.White@COMPAQ.com>
Date: Wed, 30 Aug 2000 21:37:07 +0000
Subject: [Linux-ia64] iosapic_vector struct in Linux IA64?
Message-Id: <marc-linux-ia64-105590678205420@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I am looking at an issue with Linux IA64, and the problem appears to be that
the ioapic_vector struct (iosapic.h) has only room for one
PCI/Bus/Dev/Func/Pin per PID entry... 

Being PCI devices can share interrupts, How do you handle that with only one
Entry?  Being even the PIN is part of the entry, you could not even Tie INTA
& INTC together.   

Is anyone looking into this issue? 

