From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 29 Jan 2002 08:39:34 +0000
Subject: Re: [Linux-ia64] Offsets from C struct into assembler
Message-Id: <marc-linux-ia64-105590698805948@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805940@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805940@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 29 Jan 2002 08:06:46 +0100, Christian Hildner <christian.hildner@hob.de> said:

  Christian> Although it would be a nice feature of the gcc if it
  Christian> could include C headers combined with an assembler
  Christian> directive for using the offsets the simple solution with
  Christian> print_offsets does it's job fine. The good thing here is
  Christian> that awk isn't needed.

It's not difficult to fix print_offsets.c to avoid awk.  We could use
directives of the form:

  asm volatile ("uc_rnat = %0"::"i"(offsetof (struct _Unwind_Context, rnat)));

for this purpose (this is a cut & paste from gcc's unwind-ia64.c).

	--david

