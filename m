From: Jes Sorensen <jes@sunsite.dk>
Date: Tue, 18 Sep 2001 08:05:51 +0000
Subject: Re: [Linux-ia64] Location of absolute IA32 shared objects.
Message-Id: <marc-linux-ia64-105590698805198@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805122@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805122@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Doug" = Doug Beattie <dbb@caldera.com> writes:

Doug> I just noticed a comment was posted on 2001-08-15 to the LSB
Doug> tracking task on this subject, that a post to fhs-discuss gave
Doug> the solution to the question of where ia32 vs ia64 libs should
Doug> be placed.

Doug> `The /lib directory on x86 and IA64 will always contain the
Doug> 32bit libraries. IA64 systems should put their libraries in
Doug> /lib64.' "This way we don't need any special install hooks in
Doug> the system, installer, and package. It's all hardcoded."

It's extremely nice of the FHS people to make such decisions without
consulting with the people who actually deals with the architecture in
question. Fortunately their silly decision wont have any effect here,
native libraries go in /lib and /usr/lib. They will have to change the
spec.

Keep in mind that ia32 binaries are a compatibility issue not a 'this
is what we recommend you use forever on this system' type of thing.

Jes

