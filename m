From: David Mosberger <davidm@hpl.hp.com>
Date: Sat, 23 Feb 2002 01:01:05 +0000
Subject: [Linux-ia64] Re: problem with unwind info for .init/.fini sections
Message-Id: <marc-linux-ia64-105590701905181@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905180@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905180@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 22 Feb 2002 16:58:08 -0800, Richard Henderson <rth@redhat.com> said:

  Richard> On Fri, Feb 22, 2002 at 11:54:27AM -0800, David Mosberger
  Richard> wrote:
  >> While we found the problem with ia64 linux, I suspect other
  >> platforms that rely on unwind info are likely to be affected as
  >> well.

  Richard> This is .init -- why do you care if you can unwind through
  Richard> it?

Because a debugger might need to do so.  I found the problem while
trying to print a backtrace with the Ski simulator while it was
executing inside an init function.

	--david

