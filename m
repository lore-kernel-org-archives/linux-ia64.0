From: Robert Nagy <robert.nagy@gmail.com>
Date: Tue, 26 Jun 2007 06:54:07 +0000
Subject: Re: intercept trap when running a 32bit binary
Message-Id: <20070626065407.GA886@bsd.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070625221349.GA25054@bsd.hu>
In-Reply-To: <20070625221349.GA25054@bsd.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I would have done that already of course, but the source code
is not available. This is a binary only release from http://www.valvesoftware.com/

On (25/06/07 17:04), Yu, Fenghua wrote:
> >Program terminated with signal 11, Segmentation fault.
> 
> >#0  0x40c79b0b in global constructors keyed to date () from
> >bin/engine_i686.so
> 
> >#0  0x40c79b0b in global constructors keyed to date () from
> >bin/engine_i686.so
> >No symbol table info available.
> If you can build code with symbol info, you can map the failure point to
> source code and analyze the source code.
> 
> Thanks.
> 
> -Fenghua
