From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 14 Jun 2002 18:46:13 +0000
Subject: [Linux-ia64] Re: Back to the future: which gcc for kernel 2.4.18 ?
Message-Id: <marc-linux-ia64-105590701905680@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905679@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905679@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 14 Jun 2002 14:25:50 -0400, Bill Nottingham <notting@redhat.com> said:

  Bill> Xavier Bru (Xavier.Bru@bull.net) said:
  >> Is there a clean way to do that for an unexperimented gcc user,
  >> in particular, can we have a gcc3.1 like installation that allows
  >> keeping the gcc2.96 ?

  Bill> You should be able to rebuild:

  Bill>  ftp://people.redhat.com/jakub/gcc3/3.1-1/gcc3-3.1-1.src.rpm

  Bill> and get something that installs alongside the 2.96 system
  Bill> compiler.

Your suggestion is probably better, but I also put my gcc3.1 tar-ball
at:

	ftp://ftp.hpl.hp.com/pub/linux-ia64/gcc-3.1.tar.gz

	md5sum /opt/packages/gcc-3.1.tar.gz
	4aea7b7faa76c25fc5889cafc36c5c80  /opt/packages/gcc-3.1.tar.gz

It extracts into /opt/gcc3.1 and includes the complete toolchain (gcc,
gas, ld, gdb).  As a bonus, the objdump contains the Itanium dispersal
support recently posted by the IBM folks.

As usual, no warranty etc.

	--david

