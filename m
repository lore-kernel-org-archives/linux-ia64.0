From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Tue, 25 Nov 2003 09:27:56 +0000
Subject: Re: [RFC] How drivers notice a MCA on I/O read? [1/3]
Message-Id: <marc-linux-ia64-106975273502760@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106915044130197@msgid-missing>
In-Reply-To: <marc-linux-ia64-106915044130197@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Thanks, all.

For the moment, what I mentioned was only about I/O read interface between
drivers and MCA handler, and as Zoltan mentioned, something like recovering
from each
  I/O read
  I/O write
  DMA from memory to device
  DMA from device to memory
is still left as problem to be solved. I'm glad to hear some comment about this.

Well, I'd try to carry out the codes that really consume the data without
leaning mf.a. (Since I'm not familiar with IA64 machine instruction now,
maybe it takes a long time...)

And also, I'd try to check the difference between the readb_check and usual
readb. I should reconsider my attempt if the considerable overhead exists.

Surely, readb_check concerns the interface for drivers, so I think it is better
to consider my plan of discussion on linux-kernel@vger.kern.org.

------

H.Seto <seto.hidetoshi@jp.fujitsu.com>


