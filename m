From: "David S. Miller" <davem@redhat.com>
Date: Thu, 25 Apr 2002 00:08:08 +0000
Subject: [Linux-ia64] Re: PCI DAC routines for SN
Message-Id: <marc-linux-ia64-105590701905519@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905493@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905493@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

   From: Jesse Barnes <jbarnes@sgi.com>
   Date: Wed, 24 Apr 2002 17:11:19 -0700
   
   So if performance isn't an obstacle to implementing a new call, and
   I've shown that there are platforms where 64 bit consistent mappings
   are better to use than 32 bit mappings when possible, why can't we add
   it?  Or maybe just a seperate consistent_mask that drivers could set
   to indicate they support the operation and let the platform take care
   of it?
   
Where is the platform where it is a problem to keep around
enough of the _4_ __GIGABYTES__ of consistent memory available
at bootup?

If you can't keep around enough consistent memory within the
lower 4GB, you have other problems.

Devices use, EACH, something like a few kilobytes of consistent
memory for descriptors.  If you are going to tell me this is
a big deal, you have to be kidding me.

Why don't you tell me what the real problem is?

