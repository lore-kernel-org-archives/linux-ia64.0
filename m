From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 15 Oct 2003 16:32:24 +0000
Subject: Re: IA64 ino_t incorrectly sized?
Message-Id: <marc-linux-ia64-106623593125943@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106378281914262@msgid-missing>
In-Reply-To: <marc-linux-ia64-106378281914262@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 15 Oct 2003 16:34:09 +1000, Nathan Scott <nathans@sgi.com> said:

  Nathan> On Tue, Oct 14, 2003 at 11:21:09PM -0700, David Mosberger
  Nathan> wrote:
  >> >>>>> On Wed, 15 Oct 2003 16:06:02 +1000, Nathan Scott
  >> <nathans@sgi.com> said:

  Nathan> It turns out that neither is a problem for us in practice.
  >>  Sounds find to me, then.  Except, I'd replace #ifdef __ia64__
  >> with #ifdef CONFIG_IA64, so you're relying (less) on compiler
  >> magic.


  Nathan> Oh.  I had avoided that because it requires any sources
  Nathan> including these headers to have already included
  Nathan> linux/config.h, which they may not be doing.  linux/types.h
  Nathan> is included by userspace code too, I believe, so may be an
  Nathan> issue there too.

OK.

Upon further investigation, I found that glibc defines its own "struct
ustat" and, guess what, it already declare __ino_t as unsigned long:

 (gdb) ptype struct ustat
 type = struct ustat {
     __daddr_t f_tfree;
     __ino_t f_tinode;
     char f_fname[6];
     char f_fpack[6];
 }
 (gdb) ptype __ino_t
 type = long unsigned int

So there is no need to have that ugly #ifdef for struct ustat.

I'm not 100% sure yet what to do about NFS.

	--david
