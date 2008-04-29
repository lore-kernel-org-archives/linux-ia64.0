From: Arjan van de Ven <arjan@infradead.org>
Date: Tue, 29 Apr 2008 16:42:18 +0000
Subject: Re: 2.6.25 new perfmon kernel patch + libpfm + pfmon available
Message-Id: <20080429094218.170a349c@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <7c86c4470804291446l4693b317ha7ee2382d00e99e6@mail.gmail.com>
	<7c86c4470804291447w713934a7o2b8a5a690fc9a535@mail.gmail.com>
	<20080429080853.48c66b29@infradead.org>
	<7c86c4470804300611s7442fe11lba2b66f5a3a8ed88@mail.gmail.com>
	<20080429083334.1a019318@infradead.org>
	<7c86c4470804300651u5a8fc98dr56fd1834ba902a0e@mail.gmail.com>
In-Reply-To: <7c86c4470804300651u5a8fc98dr56fd1834ba902a0e@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: stephane eranian <eranian@googlemail.com>
Cc: linux-kernel@vger.kernel.org, ia64 <linux-ia64@vger.kernel.org>, Robert Richter <robert.richter@amd.com>

On Wed, 30 Apr 2008 15:51:39 +0200
"stephane eranian" <eranian@googlemail.com> wrote:

> If I recall, AMD said that this special initialization would
> eventually migrate into the core kernel. The pci_read() may be there
> because it was not exported by the kernel (this particular code lives
> in a kernel module).

... yet your patch adds an EXPORT_SYMBOL() just to make this specific function possible. Weird.

I find it hard to believe that there would be no code in the kernel to
read or write config space of a device you have..... :)
In fact I bet 80% of the drivers in the tree use it.

