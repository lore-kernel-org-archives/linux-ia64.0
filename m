From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Wed, 20 Aug 2008 01:39:22 +0000
Subject: Re: kernel unaligned accesses on IA64 in IDE
Message-Id: <87pro4v511.wl%peterc@chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080819225606.GB22088@us.ibm.com>
In-Reply-To: <20080819225606.GB22088@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: tony.luck@intel.com, bzolnier@gmail.com, linux-ia64@vger.kernel.org, linux-ide@vger.kernel.org

>>>>> "Nishanth" = Nishanth Aravamudan <nacc@us.ibm.com> writes:

Nishanth> Hi Tony, Bart, As mentioned in the cpu_clock() thread, I am
Nishanth> seeing (consistently) 5 unaligned accesses in the bootlogs
Nishanth> on a 2-node IA64 box:

First thing to do is to work out more precisely where the unaligned
access is happening.  I suggest you recompile your kernel with debug
info, and use GDB to find the actual line number of the unaligned access.

--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
http://www.ertos.nicta.com.au           ERTOS within National ICT Australia
