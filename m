From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 14 Feb 2005 21:40:55 +0000
Subject: RE: CPU Hotplug - Support for BSP removal
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02E64C7E@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050212071417.B26140@unix-os.sc.intel.com>
In-Reply-To: <20050212071417.B26140@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>  In my reading of the spec, I don't see how we can count on the BSP b0
>being the appropriate value for return to SAL.  If I don't enable the
>fixup option, we branch off to some bad address and the CPU is lost.
>With the fixup, hotplugging the BSP on and rx2600 seems to work.

Correct.

Elilo makes no attempt to pass anything to the OS in "b0" (so it will
actually contain whatever was left in b0 after the last function call
made by elilo[1]).  I doubt that this could be fixed in elilo ... the value
in b0 when elilo is started presumably just points back to some point
in the EFI shell [I think I've seen elilo exit and just go back to EFI,
but I may either be misremembering, of misunderstanding the code sequence
that occurred to get back to the EFI shell].

-Tony

[1] and since the memory that elilo occupied will have been freed by
the time you try to take a cpu offline, this is effectively a garbage
pointer.
