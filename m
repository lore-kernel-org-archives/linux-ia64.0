From: Jim Wilson <wilson@specifixinc.com>
Date: Mon, 12 Apr 2004 23:01:48 +0000
Subject: Re: syscall_linkage
Message-Id: <1081810908.1054.4.camel@leaf.tuliptree.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <407575C0.840593AC@nospam.org>
In-Reply-To: <407575C0.840593AC@nospam.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 2004-04-08 at 08:54, Zoltan Menyhart wrote:
> Can somebody explain me, please, what the difference is between an
> __attribute__((syscall_linkage)) call and a regular one ?

It also prohibits use of input registers for local values, thus helping
to prevent kernel data from accidentally leaking back to application
code.  The input registers will be visible to the caller after the
syscall returns because of the register windows.

See the gcc code that implements syscall_linkage in
gcc/config/ia64/ia64.c.
-- 
Jim Wilson, GNU Tools Support, http://www.SpecifixInc.com

