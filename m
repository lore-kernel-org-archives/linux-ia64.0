From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 13 May 2002 20:26:50 +0000
Subject: Re: [Linux-ia64] Problem about NVidia driver 1.0-2880 on Linux-ia64 kernel 2.4.18
Message-Id: <marc-linux-ia64-105590701905578@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905571@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905571@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I think this particular problem is a user-level issue and unrelated to
the binary-only driver.

I'm not sure what's wrong here, but one experiment that you might want
to try is to build your OpenGL application against the normal XFree86
libraries.  Once you have the binary, you should be able to switch to
the Nvidia libraries.  Hopefully, that will make the problem go away
without losing performance.

	--david

>>>>> On Sun, 12 May 2002 15:30:18 -0600, n0ano@indstorage.com said:

  Don> Yi- Last I heard nVidia drivers for Linux consisted of source
  Don> wrappers around a binary only driver.  Unless you can get
  Don> nVidia to release ALL of their driver source (extremely
  Don> unlikely) or, alternatively, get nVidia to rlease IA64 binaries
  Don> you're pretty much out of luck.

  Don> On Sat, May 11, 2002 at 04:59:59PM +0800, Wang Yi wrote:
  >> There is no any mistake reported when build and install
  >> NVIDIA_kernel dirver and NVIDIA_GLX driver.  glxinfo of XFree86
  >> can provide corrent information after the new driver is
  >> installed.  My OpenGL programs work well without
  >> recompilation.But when I rebuild them, the ld report
  >> /usr/lib/libGLcore.so.1: undefined reference to '__nvsym10421'
  >> 
  >> The RedHat Linux for Itanium 7.1 installed on my machine has a
  >> version 2.4.3 kernel, which cannot match the requirement of the
  >> NVdriver. So I downloaded and installed the 2.4.18 kernel.  I
  >> unpack linux kernel 2.4.18 at ~/linux and build it
  >> successfully. It works well also.
  >> 
  >> when I build the NVIDIA_kernel driver, I use the following
  >> command : make SYSINCLUDE=~/linux/include
  >> 
  >> I have tried several time to rebuild the driver. But the results
  >> are same.

  Don> Content-Description: Card for Wang Yi


  Don> -- Don Dugger "Censeo Toto nos in Kansa esse decisse." -
  Don> D. Gale n0ano@indstorage.com Ph: 303/652-0870x117

  Don> _______________________________________________ Linux-IA64
  Don> mailing list Linux-IA64@linuxia64.org
  Don> http://lists.linuxia64.org/lists/listinfo/linux-ia64

