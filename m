From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 16 Dec 2002 22:08:43 +0000
Subject: Re: [Linux-ia64] gas generates incorrect ia64 unwind rlen values
Message-Id: <marc-linux-ia64-105590709805575@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805566@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805566@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 16 Dec 2002 12:24:03 +1100, Keith Owens <kaos@sgi.com> said:

  Keith> Using binutils-2.11.90.0.8-12 (old I know, but it is the only version
  Keith> supported on Redhat ia64), the rlen field in the body part of the
  Keith> unwind descriptors is incorrect, it is short of the real body size.

There have been many unwind-related bug fixes to the toolchain.  It's
one reason why 2.9x is hopelessly obsolete.  Distros should really
switch to gcc-3.2.

	--david

