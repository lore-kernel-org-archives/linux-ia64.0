From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 22 Apr 2002 15:34:39 +0000
Subject: Re: [Linux-ia64] new kernel patch (relative to 2.4.18)
Message-Id: <marc-linux-ia64-105590701905490@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905293@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905293@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 22 Apr 2002 16:57:20 +0200, Andreas Schwab <schwab@suse.de> said:

  Andreas> n0ano@indstorage.com writes: |> Yoav- |> |> Simple answer:
  Andreas> Yes, it can be safely removed.  |> |> Longer answer: David
  Andreas> likes to use `gdb' to track down bugs, it makes life |>
  Andreas> easier to take a fault address and use `gdb' to find the
  Andreas> exact source line |> that caused the error.  I personally
  Andreas> don't like the size of the boot image |> file that this
  Andreas> creates so one of the first things I've always done after
  Andreas> |> applying all of the IA64 patches is remove this flag.
  Andreas> Use it or not, |> whatever you prefer.

  Andreas> Or just use "strip -g".

Or "make compressed", which will give you vmlinux (with debug info),
and vmlinux.gz (without debug info).

	--david

