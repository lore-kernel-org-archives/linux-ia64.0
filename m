From: Keith Owens <kaos@ocs.com.au>
Date: Thu, 22 Dec 2005 06:26:12 +0000
Subject: Re: [PATCH 3/4] per-platform IA64_{FIRST,LAST}_DEVICE_VECTOR definitions
Message-Id: <8995.1135232772@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: Your message of "Wed, 21 Dec 2005 12:32:20 PDT."
             <20051221193220.GF2361@parisc-linux.org> 
References: <20051221184353.5003.87888.74327@attica.americas.sgi.com>
In-Reply-To: <20051221184353.5003.87888.74327@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Matthew Wilcox <matthew@wil.cx>
Cc: Mark Maule <maule@sgi.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Tony Luck <tony.luck@intel.com>

On Wed, 21 Dec 2005 12:32:20 -0700, 
Matthew Wilcox <matthew@wil.cx> wrote:
>On Wed, Dec 21, 2005 at 01:18:43PM -0600, Mark Maule wrote:
>> Ok.  Was just following the lead of this:
>> 
>> static struct msi_desc* msi_desc[NR_IRQS] = { [0 ... NR_IRQS-1] = NULL };
>> 
>> So arrays are always init'd to zero?
>
>Static variables without an initialiser go to the bss section and get
>initialised to 0 by the loader.  So the initialisation above is
>redundant on all machines which use a bitpattern of zeros to represent
>the NULL pointer.  Which is all machines Linux runs on.

Semi off topic nit pick.  C99 standard, section 6.7.8, note 10.

"... If an object that has static storage duration is not initialized
explicitly, then:

— if it has pointer type, it is initialized to a null pointer;
— if it has arithmetic type, it is initialized to (positive or
  unsigned) zero;
— if it is an aggregate, every member is initialized (recursively)
  according to these rules;
— if it is a union, the ﬁrst named member is initialized
  (recursively) according to these rules."

On the off chance that Linux is ever implemented on a machine that does
not use zeroes for a NULL pointer, it would be the compiler's job to
correctly initialise a pointer or array of pointers.

