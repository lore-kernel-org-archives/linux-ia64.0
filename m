From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 03 Feb 2005 03:52:54 +0000
Subject: Re: Abusing region 0
Message-Id: <16897.40982.47145.796311@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42017845.9080507@free.fr>
In-Reply-To: <42017845.9080507@free.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 03 Feb 2005 02:03:01 +0100, "Menyhart, Zoltan" <Zoltan.Menyhart@free.fr> said:

  Zoltan> I am going to do some experiments: I am going to map some of
  Zoltan> the virtual address ranges of a process into the address
  Zoltan> space of another one. They are real 64 bit processes,
  Zoltan> i.e. the region 0 is not used.  Can I abuse this region 0
  Zoltan> for mapping the addresses of the neighbor process into this
  Zoltan> region ? E.g. if process A has got an address at
  Zoltan> 0x6000000000001000, then I am going to map it for B at
  Zoltan> address 0x0000000000001000 ? Wont anything break ?

  Zoltan> (I need this trick because the source address can correspond
  Zoltan> to anything, like initialized data, BSS, anonymous
  Zoltan> allocation, etc, i.e.  some SHM just wont work.)

  Zoltan> Any advice will be appreciated.

Yes, you can do this.  There is nothing special about region 0 as far
as the kernel is concerned.  Well, I'm lying: the one thing that's
special is that there is a NaT page mapped at address 0 to catch
speculative accesses through a NULL-pointer.  Because of that, I'd
recommend to use an address greater than 64KB (the largest base
page-size supported by Linux).

	--david
