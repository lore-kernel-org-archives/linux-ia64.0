From: Arjan van de Ven <arjanv@redhat.com>
Date: Mon, 03 Dec 2001 21:53:42 +0000
Subject: Re: [Linux-ia64] patch to no longer use ia64's software mmu
Message-Id: <marc-linux-ia64-105590698805589@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805585@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805585@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Dec 03, 2001 at 01:47:41PM -0800, David Mosberger wrote:

> How soon will Jens' patch make it into the official tree?  I think
> that would be a pre-requisite before switching to a highmem based
> implementation.

I understood (and hope) "soon". 

> Another concern I have is that, fundamentally, I dislike the idea of
> penalizing all IA-64 platforms due to one chipset that is, shall we
> say, "lacking" (i.e., doesn't have an I/O TLB).

I think some of it (if not all) can be abstracted in the machine vectors;
setting CONFIG_HIGHMEM doesn't hurt anything; the only important part is
where you put > 4Gb memory, eg in the NORMAL or HIGH zone. That choice,
while hardcoded in my patch, can obviously be made at runtime based on
capabilities of the machine... (the remaining overhead due to 
kmap is (almost) zero already as the compiler will basically optimize 
the inline away as it's a nop in the context of the users)

Greetings,
   Arjan van de Ven

