From: Jes Sorensen <jes@linuxcare.com>
Date: Thu, 26 Oct 2000 14:10:58 +0000
Subject: Re: [Linux-ia64] Working gcc for IA64 with unwind support
Message-Id: <marc-linux-ia64-105590678205633@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205631@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205631@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Keith" = Keith Owens <kaos@ocs.com.au> writes:

Keith> Does anybody have a working toolchain for IA64 that supports
Keith> the latest unwind descriptors?  Preferably one that actually
Keith> cross compiles from ix86.

Keith> The CVS gcc has broken cross compile ix86->IA64, incorrect
Keith> optimization (bug C/645), spurious warning messages, no crt1
Keith> etc.  After working around the gcc problems, the resulting
Keith> kernel will not boot, it breaks during efi time initialization.

Have you tried Jim's Oct-24 release from ftp.cygnus.com
/pub/ia64-linux/?

Jes

