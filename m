From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 08 Feb 2005 18:17:46 +0000
Subject: Re: IA64 memory
Message-Id: <16905.586.233057.552011@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <851caabb05020220513945437@mail.gmail.com>
In-Reply-To: <851caabb05020220513945437@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sun, 6 Feb 2005 11:39:02 +0530, Vaibhav Sharma <vaibhav.sh@gmail.com> said:

  Vaibhav> Actually, my task requires me to modify the available
  Vaibhav> physical memory.  I was trying to locate the place where
  Vaibhav> the kernel stores the amount of memory. Is this value
  Vaibhav> stored in ia64_boot_param structure..?

That would come from the EFI memory-map.  Please read the EFI documentation.

	--david
