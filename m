From: Stephane Eranian <eranian@cello.hpl.hp.com>
Date: Tue, 25 Apr 2000 13:42:21 +0000
Subject: Re: [Linux-ia64] serial efishell anybody?
Message-Id: <marc-linux-ia64-105590678205039@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205037@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205037@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> >>>>> "Christoph" = Christoph Rohland <cr@sap.com> writes:
> 
> Christoph> Hi, I have everything working over serial line. Apparently
> Christoph> the efishell does also use the serial line. But I do not
> Christoph> know the port settings and how to adjust them.
> 
> 115k2 8n1 afaik
> 
Well, that's the speed of the serial connection by default. That's
good enough to connect a Linux serial console.

I think Roland was talking about COMPLETELY booting via serial, i.e. 
getting EFI on serial line. Yes, that's possible but I haven't
certainely tried that yet. I think you have to set some EFI variable
in NVRAM and reboot. Check out the EFI spec near the end.

-Stephane


