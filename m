From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 06 Sep 2000 21:11:33 +0000
Subject: Re: [Linux-ia64] 64 bit PCI DMA transfers?
Message-Id: <marc-linux-ia64-105590678205459@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205458@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205458@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 6 Sep 2000 12:29:19 -0700 (PDT), Nelson Escobar <nelson@myri.com> said:

  Nelson> Doing 64 bit PCI DMA transfers to memory less than 2 gigs
  Nelson> works fine.  When I use 4 gigs of memory, the physical
  Nelson> address of the last 2 gigs seems to be 0x100000000 -
  Nelson> 0x17fffffff.  When I try doing PCI DMA transfers into this
  Nelson> area, everything starts going wrong.

  Nelson> Is this a problem with the kernel?  Or is it a problem with
  Nelson> my driver? or both?

The kernel should handle this fine and if your driver is using the PCI
DMA interface, then it should work, too (assuming it's using it
correctly).

	--david

