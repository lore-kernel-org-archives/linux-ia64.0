From: Zoltan Menyhart <Zoltan.Menyhart_AT_bull.net@nospam.org>
Date: Thu, 15 Jan 2004 09:09:34 +0000
Subject: Re: Yet another MCA handler
Message-Id: <400658CE.23F6D0B4@nospam.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <40051D1B.7912DB91@nospam.org>
In-Reply-To: <40051D1B.7912DB91@nospam.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Russ Anderson wrote:
> 
> Zoltan Menyhart wrote:
> >
> > I was to write the code for the recovery for poisoned memory, too,
> > but I've got no way to provoke this kind of error
> > ( I do not really know what it like is :-) )
> 
> If you get that far, take the Intel Itanium 2 Processor
> Specification Update (December 2003) errata 78 into account
> 
> 78. L2 cache line with poison data results in unexpected fatal MCA
> 
> http://www.intel.com/design/itanium2/specupdt/251141.htm

Thanks for the hint, but as far as I can see, it's not what I look for.
This is a fatal MCA. I need something classified as recoverable
(byte 10: ERR_SEVERITY in the SAL log record header).

Zoltan Menyhart
