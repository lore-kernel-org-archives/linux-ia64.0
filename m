From: Xavier Bru  <Xavier.Bru@bull.net>
Date: Mon, 17 Jun 2002 16:12:58 +0000
Subject: [Linux-ia64] Re: Back to the future: which gcc for kernel 2.4.18 ?
Message-Id: <marc-linux-ia64-105590701905683@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905679@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905679@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Thanks to all for your help. 
I installed the gcc 3.1 from David's tar file and it's OK 
(unless the MCA, but this is an other story :-):

+BEGIN HARDWARE ERROR STATE AT MCA
SAL RECORD HEADER:  Record buffer = e000000000007000,  header size = 40
e000000000007000 00 00 00 00 a0 98 d1 04 02 00 01 00 28 07 00 00 
e000000000007010 01 05 19 00 17 06 02 20 50 6c 61 74 66 6f 72 6d 
e000000000007020 20 69 64 2d 20 4f 45 4d 
Total record length = 1832
End of SAL RECORD HEADER
+Err Record ID: 0    SAL Rev:  0.02
+Time: 06/17/2002/ 19:05:01    Severity 1
             XXXX

Xavier

David Mosberger writes:
 > >>>>> On Fri, 14 Jun 2002 14:25:50 -0400, Bill Nottingham <notting@redhat.com> said:
>  >   Bill> You should be able to rebuild:
 > 
 >   Bill>  ftp://people.redhat.com/jakub/gcc3/3.1-1/gcc3-3.1-1.src.rpm
 > 
 >   Bill> and get something that installs alongside the 2.96 system
 >   Bill> compiler.
 > 
 > Your suggestion is probably better, but I also put my gcc3.1 tar-ball
 > at:
 > 
 > 	ftp://ftp.hpl.hp.com/pub/linux-ia64/gcc-3.1.tar.gz
 > 
 > 	md5sum /opt/packages/gcc-3.1.tar.gz
 > 	4aea7b7faa76c25fc5889cafc36c5c80  /opt/packages/gcc-3.1.tar.gz
 > 
 > It extracts into /opt/gcc3.1 and includes the complete toolchain (gcc,
 > gas, ld, gdb).  As a bonus, the objdump contains the Itanium dispersal
 > support recently posted by the IBM folks.
 > 
 > As usual, no warranty etc.
 > 
 > 	--david

