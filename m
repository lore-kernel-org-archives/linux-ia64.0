From: Khalid Aziz <khalid@fc.hp.com>
Date: Mon, 18 Sep 2000 17:04:15 +0000
Subject: Re: [Linux-ia64] Re: KGDB patch for ia64 for 2.4.0-testN
Message-Id: <marc-linux-ia64-105590678205499@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205457@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205457@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Christoph Rohland wrote:
> 
> "Woller, Thomas" <twoller@crystal.cirrus.com> writes:
> 
> > anyone have a KGDB patch for ia64 SMP 2.4.0-testN?  UP is also ok.
> > or another recommendation for a kernel level debugger for Linux ia64.
> 
> http://kgdb.sourceforge.net/
> 
> Greetings

The code at http://kgdb.sourceforge.net/ is targeted at x86 kernel. I am
looking into doing the same for IA64 kernel. I will leverage Amit Kale's
work at http://kgdb.sourceforge.net/ as much as possible.

--
Khalid
 
==================================
Khalid Aziz                        Unix System Enablement Laboratory
(970)898-9214                                        Hewlett-Packard
khalid@fc.hp.com                                    Fort Collins, CO
==================================

