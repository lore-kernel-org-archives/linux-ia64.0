From: Christoph Rohland <cr@sap.com>
Date: Wed, 19 Jul 2000 15:17:04 +0000
Subject: [Linux-ia64] Re: Support for more than 2GB RAM
Message-Id: <marc-linux-ia64-105590678205211@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205208@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205208@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

"Akbar A." <syedali011@earthlink.net> writes:

> >and I can only use 2GB of my 4GB machine?
> pardon my naivety, but wasn't the whole point of moving to the the 64 bit
> architecture was to push and solve the problems of--
> 	o larger numbers.
> 	o allowing more memory.
> 	o larger number transactions (finance and tax applications)
> 	o large disk sizes, etc..
> 	o higher precision in scientfic simulators, and other simuation machines.
> As well as to get ride of the control Microsoft has over the IBM's and
> dells. Just had to add that bit in there, read the court findings you know.

Yes, of course 64Bit makes it much easier to support and deploy more
memory. But there are still some issues to resolve, like PCI cards
which can only access 2GB of memory. So there is often a (transient)
limitation on maximum memory supported.

Greetings
		Christoph


