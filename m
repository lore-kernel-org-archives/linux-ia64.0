From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Mon, 04 Dec 2006 23:17:24 +0000
Subject: Re: Mapping IIP value to Kernel Symbols
Message-Id: <87ejrfntdn.wl%peterc@chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <5e0a1fd80612010600q37908483n83de1ddf1d89255f@mail.gmail.com>
In-Reply-To: <5e0a1fd80612010600q37908483n83de1ddf1d89255f@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Karthik" = Karthik Gopalakrishnan <karthik.g.krishnan@gmail.com> writes:

Karthik> Hi All.  I have a value of IIP that I recovered from an
Karthik> MCA. I want to figure out which instruction in the Kernel
Karthik> resulted in the MCA. 

I find the simplest way is usually to use gdb.

 gdb vmlinux
 gdb> x/i 0xaddress

You can also do
 gdb> list *0xaddress
to find the line iff the kernel was compiled with debugging info and
you have the source available.

--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
http://www.ertos.nicta.com.au           ERTOS within National ICT Australia
