From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 25 Dec 2003 00:25:01 +0000
Subject: RE: segv at strcmp
Message-Id: <marc-linux-ia64-107231192412390@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107230762310061@msgid-missing>
In-Reply-To: <marc-linux-ia64-107230762310061@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> We have hit a problem with strcmp() on UnitedLinux 1.0
> with kernel: 2.4.19 and glibc: 2.2.5.
> I am wondering if anybody has seen something like it
> or knows if already there is a patch. I do not have a
> small repro but i will try to explain:
> 
> The segv happens at memcmp() at a line like:
> 'strcmp(x, "this is 24 chars long")' where x is a char
> pointer with a length of 7 and the constant has a
> length of 24. x is located at the first 8 bytes of the
> last 16 bytes at the end of a non-contiguous shared
> memory segment. memcmp() segvs when it tries to load 8
> bytes from the "r19" register which initially has the
> address of x and points to the end of the segment when
> the segv happens.

Sounds like your compiler converted the strcmp(str, const_str)
into memcmp(str, const_str, strlen(const_str)) ... and then
the memcmp fell off the end of the page.

What version of gcc are you using, and what arguments are you
passing to gcc?

-Tony
