From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Thu, 15 Jun 2006 21:21:41 +0000
Subject: RE: [RFC][PATCH]fix search_extable() to find correct entry
Message-Id: <000101c690c1$b4444a20$e434030a@amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <44916017.5050006@sdl.hitachi.co.jp>
In-Reply-To: <44916017.5050006@sdl.hitachi.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Masami Hiramatsu wrote on Thursday, June 15, 2006 6:27 AM
> I found a suspicious buggy code in the linux kernel on IA64 arch.
> As far as I can see, search_extable() doesn't work correctly, because
> the lookup routine expects that the address format of the
> exception_table_entry is "IP + slot", but the compiler (gcc-3.4.5)
> generates it as "IP + (slot << 2)". Thus the lookup routine always
> fails to find the corresponding entry.
> You can check it by dumping __ex_table section of vmlinux.


Are you sure about the exception table being wrong?  A quick look on my
system indicates that the compiler only generate bundle address, there
is no inter-bundle address in the exception table.

I can explain the data in continuation address. Since there is no exception
code that starts at inter-bundle address, it should always be bundle aligned,
i.e., slot will always be zero.

But the tag address in the table is also bundle aligned, which I will look
a bit more.


# gcc -v
Reading specs from /usr/lib/gcc/ia64-redhat-linux/3.4.5/specs
Configured with: ../configure --prefix=/usr --mandir=/usr/share/man --infodir=/usr/share/info --enable-shared --enable-threads=posix
--disable-checking --with-system-zlib --enable-__cxa_atexit --disable-libunwind-exceptions --enable-java-awt=gtk
--host=ia64-redhat-linux
Thread model: posix
gcc version 3.4.5 20051201 (Red Hat 3.4.5-2)
