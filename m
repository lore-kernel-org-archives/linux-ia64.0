From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 28 Sep 2001 16:13:24 +0000
Subject: [Linux-ia64] Re: kernel update (relative to 2.4.10)
Message-Id: <marc-linux-ia64-105590698805274@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205855@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205855@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 28 Sep 2001 11:32:05 -0400, Bill Nottingham <notting@redhat.com> said:

  Bill> Speaking of which, are people having success with the DRM code
  Bill> and XFree86 4.1? On my r128 (AGP), it loads and runs OK, but
  Bill> the rendering is rather broken.

It's entirely possible that I made a mistake when merging the DRM/AGP
patches in 2.4.10.  There were a bunch of conflicts which I resolved
as best as I could.  But I can't do much testing myself: the only
AGP-enabled card I have is a quadro pro but the nVidia beta driver
reboots the machine instantly with more recent kernels (I suspect this
has to do with the DRM cleanups that went in a while ago; it works
fine with a 2.4.3 kernel).

Chris do you have any updates pending?

	--david

