From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 09 May 2005 13:31:45 +0000
Subject: Re: mem_map
Message-Id: <17023.26177.377922.550436@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <851caabb05050607291364149a@mail.gmail.com>
In-Reply-To: <851caabb05050607291364149a@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 6 May 2005 19:59:59 +0530, Vaibhav Sharma <vaibhav.sh@gmail.com> said:

  Vaibhav> hi all, Can any body provide any information for the
  Vaibhav> significance of "CONFIG_VIRTUAL_MEM_MAP"?

Turning on this option puts the Linux physical memory-map (mem_map)
into virtual memory rather than physical memory.  Doing so can be an
advantage on machines which have holes in the physical memory.  For
example, on zx1-based machines, physical memory 1GB-4GB shows up at an
address above 257GB so there is a hole of about 256GB below that
address.

There are other ways to manage (huge) holes in physical memory space,
but with the large page-sizes (64MB or 16MB) we use on ia64 for
identity-mapping kernel space, this approach seems to work quite well.

	--david
