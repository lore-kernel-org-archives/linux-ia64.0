From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 16 Sep 2003 23:18:12 +0000
Subject: Re: text base address of a library
Message-Id: <marc-linux-ia64-106375429823565@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106375355522819@msgid-missing>
In-Reply-To: <marc-linux-ia64-106375355522819@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 16 Sep 2003 16:05:53 -0700, Umut Aymakoglu <umuta@us.ibm.com> said:

  Umut> Hi - Is there a way(function) to find the text base address of
  Umut> a loaded library?

  Umut> a.c: main() { b(); }

  Umut> b.c: b() {}

  Umut> %gcc -c b.c %gcc -shared -o b.sl b.o %gcc -o a a.c ./b.sl

  Umut> %ldd a ./c.sl => ./c.sl (0x2000000000044000) <---------- how
  Umut> can i find this address within a program?

dl_iterate_phdr() is probably what you want.  For better or worse, it
is said to be a trivial interface which requires no documentation [1].
libunwind has some sample code which may help you (see
src/ia64/tables-ia64.c).

	--david

[1] http://sources.redhat.com/ml/libc-alpha/2003-02/msg00031.html
