From: "White, Charles" <Charles.White@COMPAQ.com>
Date: Mon, 23 Oct 2000 16:11:28 +0000
Subject: [Linux-ia64] iosapic_vector struct in Linux IA64?
Message-Id: <marc-linux-ia64-105590678205607@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205420@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205420@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I am looking at an issue with Linux IA64, and the problem appears to be that
the ioapic_vector struct (iosapic.h) has only room for one
PCI/Bus/Dev/Func/Pin per PID entry... 
Being PCI devices can share interrupts, How do you handle that with only one
Entry?  Being even the PIN is part of the entry, you could not even tie INTA
& INTC together.   
Is anyone looking into this issue?  Has anyone been working on a fix? 


