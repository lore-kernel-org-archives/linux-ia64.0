From: Keith Owens <kaos@melbourne.sgi.com>
Date: Mon, 23 Jul 2001 14:16:18 +0000
Subject: Re: [Linux-ia64] XFS / IA64 system call conflict
Message-Id: <marc-linux-ia64-105590693005870@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005867@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005867@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 23 Jul 2001 15:53:06 +0200 (CEST), 
Martin Wilck <Martin.Wilck@fujitsu-siemens.com> wrote:
>David's last patch assigns the system call number 1215 to "getunwind".
>The XFS kernel patch for 2.4.5 vuses 1215-1217 for address control lists.
>How should this conflict be resolved? For now, I have just made XFS use
>1216-1218 instead.

The XFS syscalls for IA64 are now
        data8 sys_attrctl                       // 1260
        data8 sys_acl_get
        data8 sys_acl_set
with corresponding changes to include/asm-ia64/unistd.h.

I did some SGI internal patches for XFS+KDB against IA64 a few weeks
ago.  The problem is that IA64 is stuck on kernel 2.4.5 while XFS
development is up to 2.4.7.  There were changes to common kernel code
between 2.4.5 and 2.4.7 that affected fs handling so we cannot backport
the current XFS to the 2.4.5 IA64 kernel.  Instead I used a snapshot of
XFS as of 2.4.5, which means it is missing some bug fixes.  We would
really like a current IA64 kernel.


