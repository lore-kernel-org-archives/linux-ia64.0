From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 20 May 2002 15:57:59 +0000
Subject: [Linux-ia64] Re: Add reserved number for security syscall
Message-Id: <marc-linux-ia64-105590701905584@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 15 May 2002 17:17:33 -0700, richard offer <offer@sgi.com> said:

  Richard> Please apply the attached patch (against 2.4.18) to reserve
  Richard> a syscall number for the security interface.

  Richard> A number has already been reserved and accepted by Linus
  Richard> for the i386, alpha and cris architectures, at the time the
  Richard> reservation was requested, none of the LSM developers had
  Richard> IA64 machines so it slipped through the cracks.

  Richard> +#define __NR_security 1217 /* syscall for security modules */

1217 is already taken (setxattr in 2.5).  I assigned 1233 instead.
In the future, please send patches that apply with "patch -p1".

Thanks,

	--david

