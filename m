From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 04 Feb 2005 02:31:36 +0000
Subject: Re: IA64 memory
Message-Id: <16898.56968.259418.807911@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <851caabb05020220513945437@mail.gmail.com>
In-Reply-To: <851caabb05020220513945437@mail.gmail.com>
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 3 Feb 2005 12:33:40 +0530, Vaibhav Sharma <vaibhav.sh@gmail.com> said:

  Vaibhav> Hi, Thanks a lot for a quick response, I appreciate.  If
  Vaibhav> you could only help me out a little more $,1s&(B.

  Vaibhav> See, I need to change some of the boot parameters as
  Vaibhav> read/seen by the kernel. Once these parameters have been
  Vaibhav> setup by elilo, the Kernel must read it from these
  Vaibhav> predefined areas in memory, into some of its variables. I
  Vaibhav> need to understand where this reading part happens in the
  Vaibhav> kernel. This is where I want to modify the resources, for
  Vaibhav> future use by the kernel !! I don't want to touch the elilo
  Vaibhav> source, only the kernel.

Why not grep the sources for ia64_boot_param?

	--david

