From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 14 Sep 2001 15:51:34 +0000
Subject: Re: [Linux-ia64] Location of absolute IA32 shared objects.
Message-Id: <marc-linux-ia64-105590698805183@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805122@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805122@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 14 Sep 2001 08:30:22 -0600, Doug Beattie <dbb@caldera.com> said:

  Doug> I just noticed a comment was posted on 2001-08-15 to the LSB
  Doug> tracking task on this subject, that a post to fhs-discuss gave
  Doug> the solution to the question of where ia32 vs ia64 libs should
  Doug> be placed.

  Doug> `The /lib directory on x86 and IA64 will always contain the
  Doug> 32bit libraries. IA64 systems should put their libraries in
  Doug> /lib64.' "This way we don't need any special install hooks in
  Doug> the system, installer, and package. It's all hardcoded."

  Doug> The description above are a paraphrase and direct quote from
  Doug> the post to LSB task number 32642 that was used to track what
  Doug> should be done for LSB compatibility.

And we already have discussed this option on the ia64 lists a long
time ago and we rejected it due to source compatibility issues.  /lib
and /usr/lib must contain the native libraries, period.

	--david

