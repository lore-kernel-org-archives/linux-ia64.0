From: "Yu, Fenghua" <fenghua.yu@intel.com>
Date: Fri, 10 Jul 2009 21:01:55 +0000
Subject: RE: sydbox and ia64
Message-Id: <A6AD88C3F2289247BE726C37303E1EB8B06CAA7A@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090710160603.GE749@harikalardiyari>
In-Reply-To: <20090710160603.GE749@harikalardiyari>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

>These functions more or less work fine, the two functions i need help
>with are:
>trace_set_string: Set a string argument of the system call.
>  This function is used to change some path arguments to /dev/null so
>  that the application running under sydbox thinks everything is fine
>  but in reality it writes to /dev/null, not the actual file. We call
>  this write predicted paths.
>trace_fake_stat: Fake stat buffer of stat() call.
>  This function is used to implement the so-called magic commands.
>  When run under sydbox the stat()'ing the path /dev/sydbox returns the=20
>  faked stat buffer, not the actual one (which is failure because it
>  doesn't exist.)
>
>Both of these functions use ptrace(PTRACE_POKEDATA, ...) to poke data to
>child's memory area and both of these functions don't work as expected.
>I suspect additional hackery is involved to make them work. I'd
>appreciate if anyone with knowledge about ptrace() and itanium
>processors be kind enough to look at this file and tell me what's wrong
>:-].
>Thanks in advance.
>
>
>=B9: These functions reside in trace.c which you can see here:
>   http://github.com/alip/sydbox/blob/ia64/src/trace.c
>   For those who want to clone the repository, the git url is:
>   git://github.com/alip/sydbox.git
>
What is the error of using ptrace(PTRACE_POKEDDATA, ...)? Does it return -1=
 and errno? Or peeked data is not correct?

Thanks.

-Fenghua
