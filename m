From: Steffen Persvold <sp@scali.com>
Date: Mon, 14 Oct 2002 18:17:43 +0000
Subject: Re: [Linux-ia64] BitKeeper tree for 2.4.x
Message-Id: <marc-linux-ia64-105590709805157@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805154@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805154@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 10 Oct 2002, Bjorn Helgaas wrote:

> NOTE: I removed the mmap support for MAP_WRITECOMBINED and
> MAP_NONCACHED to avoid issues with memory attribute aliasing.
> The only user of these that I know about is XFree86, which still
> seems functional when we ignore the attributes it requests.  I'm
> very interested in any problems caused by this change.
> 

Well, without MAP_WRITECOMBINED, streaming PIO accesses to the PCI bus 
drops from 330MByte/sec to approx. 100MByte/s using the Dolphin SCI card. 

This is an rather significant drop which makes the IA64 platform kind of 
uninteresting for high performance clustering (the Dolphin SCI cards are 
used for shared memory message passing between nodes).

We can of course hack this in for our usage (in our kernel driver) if you 
are totally against having it in the kernel headers, but I think since the 
hardware allows different mapping types, the kernel should take advantage 
of it.

Regards,
 -- 
  Steffen Persvold   |       Scali AS      
 mailto:sp@scali.com |  http://www.scali.com
Tel: (+47) 2262 8950 |   Olaf Helsets vei 6
Fax: (+47) 2262 8951 |   N0621 Oslo, NORWAY


