From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 14 May 2003 16:44:06 +0000
Subject: RE: [Linux-ia64] Re: [PATCH] head.S fix for unusual load addrs
Message-Id: <marc-linux-ia64-105590723705799@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705550@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705550@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> If you plan to separate text and data of the kernel be aware 
> of tpa only translating data addresses and not instruction
> addresses. We would need a tpa.d and tpa.i. I am wondering
> about the lack of "tpa.i" in the itanium architecture design.

The previous incarnations of the replicate kernel text patch
all provided both an ITR and DTR mapping for the replicated
area ... but I don't recall that tpa was the issue, I think
that there are various data-ish blobs in amongst the code that
need to be mapped ... there is definitely the .rodata

Here's some ASCII-art that shows physical layout to the left, and
virtual layout on the right.  Sections in () show up at the virtual
addresses indicated, but aren't referenced by those addresses.

We use ITR[0] and DTR[0] to map what is labelled as the PERNODE
area (each node gets a copy of the bottom sections of the kernel,
so these mappings are different for each node), and DTR[3] to map
the GLOBAL area (same mapping on all nodes).

                          GLOBAL AREA
                        +------------+
                        | .bss       |
                        |            |
                        | .data      |
                        |            |
                        | .init.data |
                        |            |
                        |(.init.text)|
   PHYSICAL             |            |
  +------------+        | (.rodata)  |
  | .bss       |        |            |
  |            |        | (.text)    |
  | .data      |        +------------+ Region5 + 8G
  |            |
  | .init.data |
  |            |
  | .init.text |
  |            |        PERNODE AREA
  | .rodata    |        +------------+
  |            |        | (.bss)     |
  | .text      |        |            |
  +------------+        | (.data)    |
                        |            |
                        |(.init.data)|
                        |            |
                        | .init.text |
                        |            |
                        | .rodata    |
                        |            |
                        | .text      |
                        +------------+ Region5 + 4G

-Tony

