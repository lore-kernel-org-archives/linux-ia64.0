From: Jes Sorensen <jes@sunsite.dk>
Date: Wed, 25 Jul 2001 15:45:46 +0000
Subject: Re: [Linux-ia64] XFS / IA64 system call conflict
Message-Id: <marc-linux-ia64-105590693005915@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005867@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005867@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Keith" = Keith Owens <kaos@melbourne.sgi.com> writes:

Keith> On Mon, 23 Jul 2001 17:19:36 -0700, David Mosberger
Keith> <davidm@hpl.hp.com> wrote:
>>  Yes, there is: you send me mail, I add the respective numbers to
>> unistd.h, and that's it.  Anyone who messes with that protocol is
>> on his/her own.

Keith> Do you take care of glibc as well?  That is where the problem
Keith> tends to occur.

There isn't really a thing as special syscall handling in glibc in
this regard. However if you want wrappers added to glibc, just mail me
and I will do it (for glibc/ia64).

Jes

