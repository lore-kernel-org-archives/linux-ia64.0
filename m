From: Jeff Garzik <jeff@garzik.org>
Date: Thu, 02 Feb 2012 15:51:20 +0000
Subject: Re: Memory corruption due to word sharing
Message-Id: <4F2AB0F8.5020207@garzik.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <CA+55aFxmdskUXX1iBaPx7rUGD95UqNJxhe1BLeVtZjqHjBpsPA@mail.gmail.com> <alpine.LRH.2.00.1202011808240.22725@twin.jikos.cz> <Pine.LNX.4.64.1202011818570.25409@wotan.suse.de> <20120201.130905.1131458895704793597.davem@davemloft.net> <4F298865.5000409@redhat.com> <CA+55aFzzaWM=EWsK1hRho27b5ePEYNkzEnqce-DmCQ3kL1w9ZA@mail.gmail.com>
In-Reply-To: <CA+55aFzzaWM=EWsK1hRho27b5ePEYNkzEnqce-DmCQ3kL1w9ZA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Jeff Law <law@redhat.com>, David Miller <davem@davemloft.net>, matz@suse.de, jkosina@suse.cz, walters@verbum.org, jack@suse.cz, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, dsterba@suse.cz, ptesarik@suse.cz, rguenther@suse.de, gcc@gcc.gnu.org

On 02/01/2012 02:09 PM, Linus Torvalds wrote:
> We have a lot of code, there's still a lot of situations left where
> bitfields are just really convenient.

Or even just s/convenient/ingrained habit/   As much as I try to avoid 
bitfields, engineers writing vendor drivers love to lay out their 
hardware structures using bitfields, leading to such crapola as

	#ifdef little endian
		a bunch of bitfields, LE arrangement
	#else
		bitfields, now in BE arrangement
	#endif

This crops up again and again in drivers :/

	Jeff


