From: Andrew Morton <akpm@osdl.org>
Date: Thu, 09 Mar 2006 12:00:21 +0000
Subject: Re: [PATCH: 000/017] (RFC)Memory hotplug for new nodes v.3.
Message-Id: <20060309040021.3cf64e4b.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060308212316.0022.Y-GOTO@jp.fujitsu.com>
In-Reply-To: <20060308212316.0022.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: tony.luck@intel.com, ak@suse.de, jschopp@austin.ibm.com, haveblue@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-ia64@vger.kernel.org

Yasunori Goto <y-goto@jp.fujitsu.com> wrote:
>
> I'll post newest patches for memory hotadd with pgdat allocation as V3.
>  There are many changes to make more common code.

General comments:

- Thanks for working against -mm.  It can be a bit of a pain, but it
  eases staging and integration later on.

- Please review all the code to check that all those functions which can
  be made static are indeed made static.  I see quite a few global
  functions there.

- Make sure that all functions which can be tagged __meminit are so tagged.

- It would be useful to build a CONFIG_MEMORY_HOTPLUG=n kernel both with
  and without the patchsets and to publish and maintain the increase in
  code size.  Ideally that increase will be zero.  Probably it won't be,
  and it'd be nice to understand why, and to minimise it.

- Arch issues:

  - Which architectures is this patchset aimed at and tested on?

  - Which other architectures might be able to use this code in the
    future?  Because we should ask the maintainers of those other
    architectures to take a look at the changes.

- What locking does node hot-add use?  There are quite a few places in
  the kernel which cheerfully iterate across node lists while assuming that
  they won't change.  The usage of stop_machine_run() is supposed to cover
  all that, I assume?

