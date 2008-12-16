From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 16 Dec 2008 23:25:40 +0000
Subject: RE: local_add_return
Message-Id: <57C9024A16AD2D4C97DC78E552063EA35C91870C@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <alpine.DEB.1.10.0812150823370.18692@gandalf.stny.rr.com>
 <200812161703.00697.rusty@rustcorp.com.au>
 <20081215.231314.92267481.davem@davemloft.net>
 <200812170908.05423.rusty@rustcorp.com.au>
In-Reply-To: <200812170908.05423.rusty@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Rusty Russell <rusty@rustcorp.com.au>, David Miller <davem@davemloft.net>
Cc: "rostedt@goodmis.org" <rostedt@goodmis.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "mathieu.desnoyers@polymtl.ca" <mathieu.desnoyers@polymtl.ca>, "paulus@samba.org" <paulus@samba.org>, "benh@kernel.crashing.org" <benh@kernel.crashing.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>

> Any chance of an IA64 or s390 run?  You can normalize if you like, since
> it's only to compare the different approaches.

-EDOESNOTCOMPILE

  CC      init/main.o
init/main.c: In function 'test_local_variants':
init/main.c:756: error: 'atomic_long_t' has no member named 'a'
make[1]: *** [init/main.o] Error 1

-Tony
