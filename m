From: Keith Owens <kaos@ocs.com.au>
Date: Wed, 10 Jan 2001 21:11:28 +0000
Subject: Re: [Linux-ia64] Undefined symbols
Message-Id: <marc-linux-ia64-105590693005017@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205911@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205911@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 10 Jan 2001 11:34:52 -0800, 
Uros Prestor <uros@turbolinux.com> wrote:
>It looks like `make dep' is broken if you're doing a parallel build.

Parallel make dep with modversions has been broken for a long time.
The current makefiles have incorrect or missing internal dependencies.
You have to workaround by

  make dep clean && make -j bzImage modules

For 2.5 the makefile system is being redesigned from scratch and will
be fully parallel, but 2.4 is beyond repair.  Just live with serial
make dep clean.


