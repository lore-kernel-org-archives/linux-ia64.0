From: "Jim Hull" <jim_hull@hp.com>
Date: Fri, 22 Nov 2002 18:08:39 +0000
Subject: RE: [Linux-ia64] New rev 2.1 SDM for Itanium published
Message-Id: <marc-linux-ia64-105590709805474@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805465@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805465@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Matt wrote:

> On Thu, Nov 21, 2002 at 07:47:11AM -0800, Mallick, Asit K wrote:
> > This version includes the 3 new instructions:
> > - atomic ops (16 byte compare and exchange)
> 
> I presume this one is not backwards-compatible with existing processor
> implementations?

Correct.

> If so, should this be noted somewhere so that naive
> people who read the manuals don't assume that it's implemented?

There is a new "ao" bit in CPUID[4], which as described on p. 1:32, will
be 1 only if the new larger atomic ops are implemented.  Do you think
this is insufficient?

 -- Jim
    HP IPF Processor Architect


