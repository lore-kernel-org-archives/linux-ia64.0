From: James E Wilson <wilson@tuliptree.org>
Date: Wed, 11 May 2005 18:36:13 +0000
Subject: Re: Divide by zero works on ia64!!!
Message-Id: <1115836573.7882.46.camel@aretha.corp.specifixinc.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1115652187.28663.4.camel@lyra.fc.hp.com>
In-Reply-To: <1115652187.28663.4.camel@lyra.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 2005-05-09 at 13:37, Gerald Pfeifer wrote:
> As Andreas pointed out, this code invokes undefined behavior.  Undefined
> here means that the result of an operation is not defined by the language
> standard, and 0 is a valid result when invoking an undefined operation.

It is undefined in C and C++, but what about other stricter languages
like Java and Ada?  I don't have language standards for either of them,
but I believe they both require exceptions here.  Then there is the
question of Fortran, which may also have something to say about this
issue.

Also, while C doesn't require an exception, it is expected behaviour for
a POSIX system, and other gcc ports make sure we get an exception.  The
MIPS gcc port for instance emits a conditional trap instruction, because
the MIPS integer divide instruction does not trap.  The IA-64 gcc port
could do likewise.

I'd call this an oversight, a quality of implementation problem for C, a
probable bug for Java and Ada, and worthy of a gcc bugzilla bug report
so that we don't forget about it.


