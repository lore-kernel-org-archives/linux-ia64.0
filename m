From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 15 Jan 2004 23:15:52 +0000
Subject: Re: Mapping addresses 0xe000... and 0xc000...
Message-Id: <16391.7976.150308.117431@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <400714D6.2080609@m6net.fr>
In-Reply-To: <400714D6.2080609@m6net.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 15 Jan 2004 23:31:50 +0100, Zoltan MENYHART <Zoltan.Menyhart@m6net.fr> said:

  Zoltan> Is it a VMM design issue not to allow automatic address
  Zoltan> mapping if the PSR.ic is off ? Should not we revise it :-) ?

In general, you can't take a fault while PSR.ic is off.  Please see
the Itanium system architecture for details (or any good kernel book
on ia64... ;-)

	--david
