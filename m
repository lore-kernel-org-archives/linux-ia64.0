From: Christoph Rohland <cr@sap.com>
Date: Tue, 25 Apr 2000 17:20:32 +0000
Subject: Re: [Linux-ia64] serial efishell anybody?
Message-Id: <marc-linux-ia64-105590678205042@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205037@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205037@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Stephane Eranian <eranian@cello.hpl.hp.com> writes:

> > 115k2 8n1 afaik
> > 
> Well, that's the speed of the serial connection by default. That's
> good enough to connect a Linux serial console.
> 
> I think Roland was talking about COMPLETELY booting via serial, i.e. 
> getting EFI on serial line. 

Yes, that's right. 

> Yes, that's possible but I haven't certainely tried that yet. I
> think you have to set some EFI variable in NVRAM and reboot. Check
> out the EFI spec near the end.

I checked the spec and found the variables to set: 

ConIn, ConOut and ErrOut

Actually ErrOut is set to the serial line on my machine. But how do I
change these variables?

Greetings
		Christoph


