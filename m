From: Bill Nottingham <notting@redhat.com>
Date: Fri, 07 Sep 2001 20:45:51 +0000
Subject: [Linux-ia64] Re: AT Keyboard not present?
Message-Id: <marc-linux-ia64-105590698805145@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

KOCHI Takayoshi (t-kouchi@mvf.biglobe.ne.jp) said: 
> It was a BigSur with a PS/2 keyboard and a PS/2 mouse.
> I didn't configure usb driver in the kernel nor load
> as a module.

I've noticed some oddness with the keyboard controller on my BigSur;
for whatever reason, on a cold boot, one keyboard I have needs replugged
for it to work. The same keyboard works fine on other machines.

Bill

