From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 07 Sep 2001 21:12:10 +0000
Subject: RE: [Linux-ia64] Re: AT Keyboard not present?
Message-Id: <marc-linux-ia64-105590698805146@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805145@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805145@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I used to have that problem with my BigSur too.  I changed
a whole bunch of things all at once when I moved the machine
from the lab to my cube, and the problem went away, so I'm
not sure what the problem was.  Here's what I changed:

	Upgraded processor from A3 to B3
	Upgraded f/w (from ?? to ?? ... I forget versions)
	Keyboard was directly connected in the lab,
	   started using a Belkin OmniCube 4-port KVM
	   switch to share keyboard between machines.
	It's not the same keyboard that was in the lab.
	Machine is now faces east instead of north :-)
	My cube is at least 10F degrees warmer than the lab.

-Tony

-----Original Message-----
From: Bill Nottingham [mailto:notting@redhat.com]
Sent: Friday, September 07, 2001 1:46 PM
To: KOCHI Takayoshi
Cc: linux-ia64@linuxia64.org
Subject: [Linux-ia64] Re: AT Keyboard not present?


KOCHI Takayoshi (t-kouchi@mvf.biglobe.ne.jp) said: 
> It was a BigSur with a PS/2 keyboard and a PS/2 mouse.
> I didn't configure usb driver in the kernel nor load
> as a module.

I've noticed some oddness with the keyboard controller on my BigSur;
for whatever reason, on a cold boot, one keyboard I have needs replugged
for it to work. The same keyboard works fine on other machines.

Bill

_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64

