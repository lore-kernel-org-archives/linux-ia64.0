From: Matt Chapman <matthewc@cse.unsw.edu.au>
Date: Fri, 22 Nov 2002 09:12:42 +0000
Subject: Re: [Linux-ia64] New rev 2.1 SDM for Itanium published
Message-Id: <marc-linux-ia64-105590709805473@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805465@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805465@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Nov 21, 2002 at 07:47:11AM -0800, Mallick, Asit K wrote:
> This version includes the 3 new instructions:
> - atomic ops (16 byte compare and exchange)

I presume this one is not backwards-compatible with existing processor
implementations?  If so, should this be noted somewhere so that naive
people who read the manuals don't assume that it's implemented?

Matt


