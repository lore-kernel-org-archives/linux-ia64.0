From: grundler@cup.hp.com (Grant Grundler)
Date: Mon, 31 Mar 2003 23:42:24 +0000
Subject: Re: [Linux-ia64] Interpreting MCA error dumps
Message-Id: <marc-linux-ia64-105590723705369@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705367@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705367@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Apr 01, 2003 at 09:27:41AM +1000, Peter Chubb wrote:
> 
> Hi,
> 	Is there any published info on interpreting MCA error dumps?
> I'm interested in working out what the error actually was, and what
> caused it.

AFAIK, Not for ZX1 chipset specific info.
You could probably get access through an NDA (aka CDA).
Not sure if Gelato program is the right place to ask but
that would be a starting point.

HP field support have access to tools that help decode MCA dumps
into human readable stuff. That was the intended use of MCA dumps
by "regular" customers.

In this case, it's probably most expedient for you to just post
a reference to the dump and whoever is available can decode for you.

grant

