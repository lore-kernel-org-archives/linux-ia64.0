From: "Brown, Len" <len.brown@intel.com>
Date: Wed, 31 Aug 2005 21:51:36 +0000
Subject: RE: One-line patch for systems with ACPI enabled but incomplete tree
Message-Id: <F7DC2337C7631D4386A2DF6E8FB22B30047B85D5@hdsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <F7DC2337C7631D4386A2DF6E8FB22B30047B83DE@hdsmsx401.amr.corp.intel.com>
In-Reply-To: <F7DC2337C7631D4386A2DF6E8FB22B30047B83DE@hdsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Magenheimer, Dan (HP Labs Fort Collins)" <dan.magenheimer@hp.com>
Cc: acpi-devel@lists.sourceforge.net, hch@infradead.org, linux-ia64@vger.kernel.org

 
>If FADT is absolutely required for every ACPI tree, I see why
>there is no check in the kernel code.  However, it still seems
>like a bug to me as everything else works if the FADT pointer
>is zero (with the above one line patch).

ACPI has to jump through a lot of hoops due to broken systems.
I don't want to add, test, and support an "FADT optional" hoop
unless absolutely necessary.

>Thanks for the pointer... I will go find it and see if I can
>leverage the code.

please do -- that is why we write it:-)

-Len
