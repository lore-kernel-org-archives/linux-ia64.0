From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 23 Jul 2001 18:51:47 +0000
Subject: Re: [Linux-ia64] XFS / IA64 system call conflict
Message-Id: <marc-linux-ia64-105590693005876@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005867@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005867@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 24 Jul 2001 00:16:18 +1000, Keith Owens <kaos@melbourne.sgi.com> said:

  Keith> The XFS syscalls for IA64 are now data8 sys_attrctl // 1260
  Keith> data8 sys_acl_get data8 sys_acl_set with corresponding
  Keith> changes to include/asm-ia64/unistd.h.

No they are not.  If you need system call numbers, send me mail and
I'll assign you the necessary numbers.

	--david

